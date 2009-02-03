package RTx::Tags;
our $VERSION = 0.12;

sub cloud{
  my %tags;

  my $cloud = RTx::Tags->new(base=>RT->Config->Get('WebPath') .
			     '/Search/Simple.html?q=.tags%3A',
			     @_);

  my $r = $RT::Handle->SimpleQuery($cloud->{_query});
  return (0, "Internal error: <$r>. Please send bug report.") unless $r;

  while( my $row = $r->fetchrow_arrayref ) {
    foreach my $k ( split/[,;\s]+/, $row->[1] ){
      $tags{$k} += $row->[0];
    }
  }

  foreach my $k ( keys %tags ){
    $cloud->add(tag=>$k, url=>$k, count=>$tags{$k}, title=>$tags{$k})
      if $tags{$k};
  }

  return $r->err ?
      (0, "Internal error: <". $r->err .">. Please send bug report.") : $cloud;
}


sub new {
  my $class = shift;
  my %args = @_;
  my %opts = $args{default} ? (LinkType=>1) :
    (LinkType=>1, RT->Config->Get('RTxTags'));

  my $self  = {
	       base   => undef,
	       levels => 24,
	       @_,
               _count => {},
               _stash => {},
	       _query => genSQL(%opts),
	      };
  $self->{_base} = '#' unless defined($opts{LinkType});

  bless $self, $class;
  return $self;
}

sub genSQL{
  my %opts = @_;
  my $SQLopts;

  my $Query = <<Preamble;
SELECT COUNT(ObjectCustomFieldValues.Content), ObjectCustomFieldValues.Content FROM ObjectCustomFieldValues JOIN CustomFields ON CustomFields.Id=ObjectCustomFieldValues.CustomField 
Preamble

  if( exists($opts{Status}) ){
    if( defined($opts{Status}) ){
      $Query .= 'JOIN Tickets ON ObjectCustomFieldValues.ObjectId=Tickets.id ';
      $SQLopts = 'AND Tickets.Status IN('.
	join(',', map {"'$_'"} @{$opts{Status}}). ') ';
    }
    $opts{Types} = ['RT::Ticket'];
  }

  if( $opts{Types} ){
    $SQLopts .= 'AND ObjectCustomFieldValues.ObjectType IN('.
      join(',', map {"'$_'"} @{$opts{Types}}). ') ';
  }

  $Query .= <<EOQ;
WHERE CustomFields.Name='Tags' AND ObjectCustomFieldValues.Disabled=0 $SQLopts GROUP BY ObjectCustomFieldValues.Content;
EOQ
}

sub add {
  my $self = shift @_;
  my %args = scalar @_ > 3 ? @_ : (tag=>$_[0], url=>$_[1], count=>$_[2]);

  my $tag = $args{tag};
  $self->{_stash}->{$tag}->{count} = $args{count};
  $self->{_stash}->{$tag}->{title} = $args{title} if defined($args{title});
  $self->{_stash}->{$tag}->{url}   = defined($self->{base}) ? 
      $self->{base} . $args{url} : $args{url};

  $self->{_count}->{$tag} = $args{count};
}

sub tags {
  my($self, $limit) = @_;
  my $counts = $self->{_count};
  my @tags = sort { $counts->{$b} <=> $counts->{$a} } keys %$counts;
  @tags = splice(@tags, 0, $limit) if defined $limit;

  return unless scalar @tags;

  my $min = log($counts->{$tags[-1]});
  my $max = log($counts->{$tags[0]});
  my $factor = 1;
  
  # special case all tags having the same count
  if ($max - $min == 0) {
    $min -= $self->{levels}; }
  else {
    $factor = $self->{levels} / ($max - $min);
  }
  
  if (scalar @tags < $self->{levels} ) {
    $factor *= (scalar @tags/$self->{levels});
  }
  my @tag_items;
  foreach my $tag (sort @tags) {
     my $tag_item = $self->{_stash}->{$tag};
     $tag_item->{name} = $tag;
     $tag_item->{level} = int((log($tag_item->{count}) - $min) * $factor);
    push @tag_items, $tag_item;
  }
  return @tag_items;
}

sub html {
  my($self, $limit) = @_;
  my @tags=$self->tags($limit);
  my $html = '';

  return($html) unless scalar(@tags);

  foreach my $tag (@tags) {
    $html .= sprintf qq(<a class="tagcloud%i" href="%s"%s>%s</a>\n),
      $tag->{level}, $tag->{url},
	(defined($tag->{title}) ? qq( title="$tag->{title}") : ''),
	 $tag->{name};
  }
  return qq{<div id="htmltagcloud">\n$html</div>};
}

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

=head2 Basic Functionality

=over

=item #

Install this module i.e; extract to F<local/plugins/RTx-Tags> & amend
F<RT_SiteConfig.pm> to include I<RTx::Tags> in C<@Plugins>.

No patching necessary! If you've previously applied  SearchCustomField from
the wiki or email list, or installed version 0.021 of this module, it is
recomended that you revert the patch. No harm will come from not doing so,
but it's best to keep RT core files vanilla where possible.

=item #

Create a custom field named C<Tags>.
Although you may add tags to any sort of object you want,
the recommended Type is I<Enter one value> with I<Applies to Tickets>.
The recommended Description is I<Freeform annotation for ready searching>.

=item #

Apply the Custom Field to the desired objects e.g; queue(s).

=back

=head2 Optional Features

=over

=item *

Add I<TagCloud> to C<$HomepageComponents> in F<RT_SiteConfig.pm> if you would
like users to have the ability to display a Tag Cloud on the front page,
and not just the Simple Search page.

=item *

Read the module configuration options, and customize to suit your taste.

  perldoc local/plugins/RTx-Tags/etc/Tags_Config.pm

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

=head1 SEE ALSO

L<RT::Search::Googleish_Local>

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

A heavily customized version of Leon Brocard's HTML::TagCloud v0.34
has been inlined since v0.10.

=head1 LICENSE

The same terms as perl itself.

=cut
