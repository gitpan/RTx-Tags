#Only display 'Active' Tickets
#Set(%RTxTags, (Status=>\@RT::ActiveStatus);

1;
__END__

=pod

=head1 OPTIONS

You may configure RTX::Tags by setting %RTxTags in
F<local/etc/Tags_Config.pm> or the default location of this document:
F<local/plugins/RTx-Tags/etc/Tags_Config.pm>.

Options only affect the tag cloud displayed on F<Search/Simple.html>
and the homepage component. You can see the default view by clicking
the title link.

Recognized keys are:

=over

=item B<Types>

Accepts an arrayref of object types to limit the count to.
By default RTx::Tags will count tags for any object in RT.

Of course, the links for each tag will only display corresponding I<tickets>.

=item B<LinkType>

If this is set to undef, tags are not linked to ticket search results.
This might be useful if your cloud features (many instances of) types
other than tickets.

=item B<Status>

Accepts an arrayref of statuses to limit the count to,
with the side-effect of forcibly limiting B<Types> to I<RT::Ticket>.

If you want to count tickets regardless of status you could use
C<Types=E<gt>'RT::Ticket'>, but C<Status=E<gt>undef> is probably clearer.

A particularly handy incantantion is:

  #Only display 'Active' Tickets
  Set(%RTxTags, (Status=>\@RT::ActiveStatus);

=back

=cut
