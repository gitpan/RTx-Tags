package RT::Search::Googleish_Overlay;
our $VERSION = 0.01;

#Hook::LexWrap won't let us tweak @_ sufficiently

my $core = \&RT::Search::Googleish::QueryToSQL;
*RT::Search::Googleish::QueryToSQL = sub {
  my $self  = shift;
  my $query = shift || $self->Argument;

  my @CF;
  while( $query =~ s/\.(\w+):(\w+)// ){
    push @CF, "CF.{$1} LIKE '$2'";
  }

  #Stupid space to overcome damn test for empty query in Googleish.pm
  my $ret = $core->($self, $query||' ', @_);
  return $ret . ' AND ' . join(' AND ', @CF);
};

1;
__END__

=head1 NAME

RT::Search::Googleish_Local - Allow searching of custom fields

=head1 DESCRIPTION

Search for customfields with C<.>I<CFName>C<:>I<value>, where I<CFName>
and I<value> match C<\w+>

=head1 LICENSE

The same terms as perl itself.
