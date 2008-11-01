package RT::Search::Googleish_Overlay;
our $VERSION = 0.03; #Forgot to bump this before, in at least .05->.06

#Hook::LexWrap won't let us tweak @_ sufficiently

my $core = \&RT::Search::Googleish::QueryToSQL;
*RT::Search::Googleish::QueryToSQL = sub {
  my $self  = shift;
  my $query = shift || $self->Argument;

  my @CF;
  while( $query =~ s/\.(\w+):(\S+)// ){
    push @CF, "CF.{$1} LIKE '$2'";
  }

  #Stupid space to overcome damn test for empty query in Googleish.pm
  my $ret = $core->($self, $query||' ', @_);
  $ret .= ' AND ' . join(' AND ', @CF) if scalar @CF;
  return $ret;
};

1;
__END__

=head1 NAME

RT::Search::Googleish_Local - Allow searching of custom fields

=head1 DESCRIPTION

Search for customfields with C<.>I<CFName>C<:>I<value>, where I<CFName>
and I<value> match C<\S+>

=head1 LICENSE

The same terms as perl itself.
