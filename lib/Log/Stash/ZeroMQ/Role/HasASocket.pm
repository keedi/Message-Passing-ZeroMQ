package Log::Stash::ZeroMQ::Role::HasASocket;
use Moose::Role;
use ZeroMQ ':all';
use Moose::Util::TypeConstraints;
use namespace::autoclean;

with 'Log::Stash::ZeroMQ::Role::HasAContext';

has _socket => (
    is => 'ro',
    isa => 'ZeroMQ::Socket',
    lazy => 1,
    builder => '_build_socket',
    predicate => '_has_socket',
    clearer => '_clear_socket',
);

before _clear_ctx => sub {
    my $self = shift;
    if (!$self->linger) {
        $self->_socket->setsockopt(ZMQ_LINGER, 0);
    }
    $self->_socket->close;
    $self->_clear_socket;
};

requires '_socket_type';

has linger => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

sub _build_socket {
    my $self = shift;
    my $type_name = "ZeroMQ::Constants::ZMQ_" . $self->socket_type;
    my $socket = $self->_ctx->socket(do { no strict 'refs'; &$type_name() });
    if (!$self->linger) {
        $socket->setsockopt(ZMQ_LINGER, 0);
    }
    $socket;
}

has socket_type => (
    isa => enum([qw[PUB SUB PUSH PULL]]),
    is => 'ro',
    builder => '_socket_type',
);

1;

=head1 NAME

Log::Stash::ZeroMQ::HasASocket - Role for instances which have a ZMQ socket.

=head1 ATTRIBUTES

=head2 linger

Bool indicating the value os the ZMQ_LINGER options.

Defaults to 0 meaning sockets are lossy, but will not block.

=head1 SPONSORSHIP

This module exists due to the wonderful people at
L<Suretec Systems|http://www.suretecsystems.com/> who sponsored it's
development.

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Log::Stash>.

=cut

