package Config::Connie::Client;

use Config::Connie::Object;

##################################################
# Our attributes: Connie instance + storage helper

has 'instance' => (is => 'ro', required => 1);

has 'id'      => (is => 'ro', default => sub { shift->instance->id });
has 'app'     => (is => 'ro', default => sub { shift->instance->app });
has 'env'     => (is => 'ro', default => sub { shift->instance->env });
has 'storage' => (is => 'ro', default => sub { $_[0]->instance->storage($_[0]) });


############################################
# Configuration local cache and manipulation

has 'cfg' => (is => 'ro', default => sub { {} });

sub get {
  my ($self, $k) = @_;
  my $cfg = $self->cfg;

  return $cfg->{$k} if exists $cfg->{$k};
  return $self->instance->default_for($k);
}

sub _set {
  my ($self, $k, $v, $now) = @_;

  $self->cfg->{$k} = $v if $now;
  $self->storage->key_updated($k, $v);

  return $v;
}

sub set { $_[0]->_set($_[1], $_[2]) }
sub set_now { $_[0]->_set($_[1], $_[2], 1) }

sub _update_key {
  my ($self, $k, $v) = @_;

  $self->cfg->{$k} = $v;
  $self->_signal_subscribers($k, $v);

  return;
}


#######################
# Configuration changes

has '_subs' => (is => 'ro', default => sub { {} });

{
  my $sub_id = 0;

  sub subscribe {
    my ($self, $k, $cb, @rest) = @_;
    my $subs = $self->_subs;

    $subs->{k}{$k}{ ++$sub_id } = [$cb, \@rest];
    $subs->{i}{$sub_id} = $k;

    return $sub_id;
  }
}

sub unsubscribe {
  my ($self, $sub_id) = @_;
  my $subs = $self->_subs;

  my $k = delete $subs->{i}{$sub_id};
  return unless defined $k;

  my $ks = $subs->{k}{$k};
  my $cb = delete $ks->{$sub_id};
  delete $subs->{k}{$k} unless %$ks;

  return $cb->[0];
}

sub _signal_subscribers {
  my ($self, $k, $v) = @_;
  my $subs = $self->_subs;

  return unless exists $subs->{k}{$k};
  for my $item (values %{ $subs->{k}{$k} }) {
    my ($cb, $rest) = @$item;
    $cb->($v, $k, $self, $rest);
  }

  return;
}


1;
