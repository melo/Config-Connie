package Config::Connie::Subscriptions;

use Moo::Role;
use namespace::autoclean;

has '_cfg_subs'   => (is => 'ro', default => sub { {} });
has '_cfg_sub_id' => (is => 'rw', default => sub {0});

sub subscribe {
  my ($self, $k, $cb, @rest) = @_;
  my $subs = $self->_cfg_subs;

  $self->_cfg_sub_id(my $id = $self->_cfg_sub_id + 1);

  $subs->{k}{$k}{$id} = [$cb, \@rest];
  $subs->{i}{$id} = $k;

  return $id;
}

sub unsubscribe {
  my ($self, $sub_id) = @_;
  my $subs = $self->_cfg_subs;

  my $k = delete $subs->{i}{$sub_id};
  return unless defined $k;

  my $ks = $subs->{k}{$k};
  my $cb = delete $ks->{$sub_id};
  delete $subs->{k}{$k} unless %$ks;

  return $cb->[0];
}

sub _signal_subscribers {
  my ($self, $k, $v) = @_;
  my $subs = $self->_cfg_subs;

  return unless exists $subs->{k}{$k};

  my $sub_count = 0;
  for my $item (values %{ $subs->{k}{$k} }) {
    my ($cb, $rest) = @$item;
    $cb->($v, $k, $self, $rest);
    $sub_count++;
  }

  return $sub_count;
}

1;
