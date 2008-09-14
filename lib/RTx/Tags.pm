package RTx::Tags;
our $VERSION = 0.021;
1;
__END__

=head1 RTx::Tags

Tag Cloud support for RT with simple-searchable custom fields.

=head1 DESCRIPTION

This module uses portions of L<HTML::TagCloud> to provide a tag cloud on
Search/Simple.html The cloud consists of the values (split on commas,
semi-colons and whitespace) for B<all objects> with the C<Tags> custom
field.

In addition to the cloud, documentation for using the Simple Searchable
Custom Fields patch is included on the page, since the patch is required
in order for the cloud links to work.

=head1 INSTALL

=over

=item # 

Install HTML::TagCloud

=item #

Install this module i.e; extract to local/plugins/RTx-Tags & ammend SiteConfig

=item #

Apply the following patch; for RT 3.8.1

  --- /tmp/Googleish.pm   2008-09-08 12:37:19.000000000 -0400
  +++ lib/RT/Search/Googleish.pm  2008-09-08 12:44:21.000000000 -0400
  @@ -141,6 +141,10 @@
      push @owner_clauses, "Owner = '" . $User->Name . "'";
  }
 
  +        elsif ( $key =~ /.(\w+):(\w+)/i ) {
  +            push @user_clauses, "CF.{$1} LIKE '$2'";
  +        }
  +
           # Else, subject must contain $key
      else {
               $key =~ s/['\\].*//g;
  [

=item #

Create a Custom Field named C<Tags>. The recommended type is "Enter one value,"
with "applies to Tickets." The recommended Description is "Freeform annotation
for ready searching,"

=item #

Apply the Custom Field to the desired queue.

=back

=head1 BUGS

=over

=item *

Due to limitations in the available callbacks, the CF search blurb and
tags cloud are output before the core search mechanism blurbs.

=item *

Due to limitations in the available callbacks, every page loads the cloud css,
which has also been hard-coded to 26 levels.

=back

=head1 LICENSE

The same terms as perl itself.
