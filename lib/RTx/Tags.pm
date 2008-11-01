package RTx::Tags;
our $VERSION = 0.07;
"Truthiness";
__END__

=head1 NAME

RTx::Tags - Tag Cloud support for RT with simple-searchable custom fields.

=head1 DESCRIPTION

This module uses portions of L<HTML::TagCloud> to provide a tag cloud on
Search/Simple.html The cloud consists of the values (split on commas,
semi-colons and whitespace) for B<all objects> with the C<Tags> custom
field.

In addition to the cloud, this module provides support for Simple Searchable
Custom Fields witha Local overlay. An explanation of this feature is also
shown on Search/Simple.html

=head1 INSTALL

=over

=item # 

Install HTML::TagCloud

=item #

Install this module i.e; extract to F<local/plugins/RTx-Tags> & amend
F<RT_SiteConfig.pm> to include I<RTx::Tags> to C<@Plugins>.

These first steps may be accomplished via CPAN(PLUS) with auto-dependencies.

=item #

No patching necessary! If you've previously applied  SearchCustomField from
the wiki or email list, or installed version 0.021 of this module, it is
recomended that you revert the patch. No harm will come from not doing so,
but it's best to keep RT core files vanilla where possible.

=item #

Create a custom field named C<Tags>. The recommended type is I<Enter one value>
with I<Applies to Tickets>. The recommended Description is
I<Freeform annotation for ready searching>.

=item #

Apply the Custom Field to the desired queue(s).

=item #

Optionally add I<TagCloud> to C<$HomepageComponents> in F<RT_SiteConfig.pm> if
you would like users to have the ability to display a Tag Cloud on the front
page, and not just the Simple Search page.

=back

=head1 CAVEATS

=over

=item *

Due to limitations in the available callbacks, the CF search blurb and tags
cloud are output before the core search mechanism blurbs on Simple Search;
postform is ugly.

=item *

Due to limitations in the available callbacks, every page links to cloud.css,
which has also been hard-coded to 26 levels.

=item *

Due to the mechanism used to implement the CF search, the presence of another
Search/Googleish_Local.pm will likely not result in behavior you desire.
Should you wish to make further local customizations, either modify this
module's code, or use Googleish_Vendor.pm

=back

=head1 LICENSE

The same terms as perl itself.
