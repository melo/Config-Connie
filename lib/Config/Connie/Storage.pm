package Config::Connie::Storage;

use Config::Connie::Object;


##########################
# Configuration management

has 'cfg' => (is => 'ro', default => sub { {} });

sub get {
  my ($self, $k) = @_;
  my $cfg = $self->cfg;

  return unless exists $cfg->{$k};
  return $cfg->{$k};
}

sub set {
  my ($self, $k, $v) = @_;
  $self->_set($k, $v);

  $self->_cfg_updated_for($k, $v);

  return $v;
}

sub _set {
  my ($self, $k, $v) = @_;
  $self->cfg->{$k} = $v;

  return;
}


#######################
# Configuration changes

has '_subs' => (is => 'ro', default => sub { {} });

{
  my $sub_id = 0;

  sub subscribe {
    my ($self, $k, $cb) = @_;
    my $subs = $self->_subs;

    $subs->{k}{$k}{ ++$sub_id } = $cb;
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

  return $cb;
}

sub _cfg_updated_for { shift->_signal_subscribers(@_) }

sub _signal_subscribers {
  my ($self, $k) = @_;
  my $subs = $self->_subs;

  return unless exists $subs->{k}{$k};
  for my $cb (values %{ $subs->{k}{$k} }) {
    $cb->($self, $k);
  }

  return;
}


##########################
# Check for config updates

sub check_once { }


1;
