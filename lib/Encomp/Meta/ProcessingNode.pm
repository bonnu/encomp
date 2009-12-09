package Encomp::Meta::ProcessingNode;

use strict;
use warnings;
use base qw/Tree::Simple/;
use Carp qw/croak/;
use Tree::Simple qw/use_weak_refs/;

use Encomp::Context;

sub new {
    my ($class, $id, $parent) = @_;
    if ($parent) {
        $parent->is_unique_on_fraternity($id)
            || croak "is not unique on fraternity : $id";
    }
    unless ($id) {
        $parent && croak 'id is necessary for the child.';
        $id = '/';
    }
    my $self = Tree::Simple::new($class, { path_cached => undef }, $parent);
    $self->setUID($id);
    return $self;
}

sub is_unique_on_fraternity {
    my ($self, $id) = @_;
    return unless defined $id && length $id;
    map { return if $_->getUID eq $id } ($self->getAllChildren);
    return 1;
}

sub _is_node {
    my $id  = shift   || return;
    my $ref = ref $id || return;
    return if $ref =~ /\A(?:ARRAY|CODE|GLOB|HASH|REF|Regexp|SCALAR)\z/o;
    return $id->isa(__PACKAGE__);
}

sub append_nodes {
    my ($self, @nodes) = @_;
    while (0 < @nodes) {
        my $id = shift @nodes;
        my $node;
        if (_is_node($id)) {
            $self->addChild($node = $id);
        }
        else {
            $node = $self->get_root->new($id, $self);
        }
        if (0 < @nodes && ref $nodes[0] eq 'ARRAY') {
            $node->append_nodes(@{ shift @nodes });
        }
    }
}

sub invoke {
    my ($self, $callback) = @_;
    my $context = Encomp::Context->new;
    do {
        last if $context->{return};
        _traverse($self, $context, $callback);
    } while ($context->{_goto});
}

sub _traverse {
    my ($self, $context, $callback) = @_;
    $context->current($self);
    $callback->($self, $context) unless $context->{skip};
    return if $context->{return};
    for my $node (@{ $self->{_children} }) {
        return unless _traverse($node, $context, $callback);
    }
    return 1;
}

sub get_path {
    my $self = shift;
    my $path;
    unless ($path = $self->{path_cached}) {
        my @path;
        my $cur = $self;
        until ($cur->isRoot) {
            unshift @path, $cur->{_uid};
            $cur = $cur->getParent;
        }
        $path = $self->{path_cached} = '/' . join '/', @path;
    }
    return $path;
}

sub get_root {
    my $self = shift;
    return $self if $self->isRoot;
    return $self->getParent->get_root;
}

sub find_by_path {
    my $self = shift;
    my @path = @_ == 1 ? split m{(?:(?<=^/)|(?<!^)/)}o, $_[0] : @_;
    my $cur  = $self;
    if (0 < @path && $path[0] eq '/') {
        shift @path;
        $cur = $self->get_root;
    }
    if (0 < @path) {
        my $id = shift @path;
        for my $child ($cur->getAllChildren) {
            return $child->find_by_path(@path) if $child->getUID eq $id;
        }
        undef $cur;
    }
    return $cur ? $cur : ();
}

sub get_all_ids {
    my $self = shift;
    my @ids;
    my $ids = \@ids;
    my $rec;
    $rec = sub {
        for my $child (@_) {
            push @{$ids}, $child->getUID;
            my $children = $child->getAllChildren;
            next unless 0 < @{$children};
            my $tmp = $ids;
            $ids = [];
            push @{$tmp}, $ids;
            $rec->(@{$children});
            $ids = $tmp;
        }
    };
    $rec->($self->getAllChildren);
    @ids;
}

1;

__END__
