package XML::Feed::JavaScript;

use 5.006001;
use strict;
use warnings;
use Carp ();
use Encode::compat;
use Encode ();
use HTML::Template;

use base qw(XML::Feed);

BEGIN {
	*XML::Feed::as_javascript   = \&as_javascript;
	*XML::Feed::save_javascript = \&save_javascript;
}

our $VERSION = '0.01';

sub as_javascript {
	my ($self, $opt) = @_;
	my $max = $opt->{max} || 10;
	my $encoding = $opt->{encoding} || 'utf8';
	my %tmpl_opt = $opt->{tmpl_opt} ?
	               %{$opt->{tmpl_opt}} :
	               (scalarref => &_js_template, die_on_bad_params => 0);

	my $i = 0;
	my @items;
	for my $entry ($self->entries) {
		last if $i >= $max;
		push @items, {
			title    => $entry->title,
			link     => $entry->link,
		};
		$i++;
	}

	my $tmpl = HTML::Template->new(%tmpl_opt);
	$tmpl->param(
		title => $self->title,
		link  => $self->link,
		items => \@items,
	);

	return _js_print(
		_convert_encoding($encoding, $tmpl->output)
	);
}

sub save_javascript {
	my ($self, $file, $opt) = @_;
	Carp::croak('You must pass in a filename to save_javascript')
		unless $file;

	open FH, "> $file"
		or Carp::croak("Cannot open file $file for write: $!");
	print FH $self->as_javascript($opt || undef);
	close FH;
}

sub _js_template {
	my $template = <<'EOS';
<div class="xml_feed">
<div class="xml_feed_title"><a href="<TMPL_VAR NAME="link" ESCAPE="HTML">"><TMPL_VAR NAME="title" ESCAPE="HTML"></a></div>
<TMPL_IF NAME="items"><ul class="xml_feed_items">
<TMPL_LOOP NAME="items">
<li><a href="<TMPL_VAR NAME="link" ESCAPE="HTML">"><TMPL_VAR NAME="title" ESCAPE="HTML"></a></li>
</TMPL_LOOP>
</ul></TMPL_IF>
</div>
EOS
	return \$template;
}

sub _convert_encoding {
	my ($encoding, $string) = @_;
	return Encode::encode($encoding, $string)
		if Encode::is_utf8($string);

	Encode::from_to($string, 'utf8', $encoding);
	return $string;
}

sub _js_print {
	my $string = shift;
	my $js;
	for my $line (split /[\n\r]+/, $string) {
		$line =~ s/\x27/&#x27/g;
		$js .= "document.writeln('$line');\n";
	}
	return $js;
}

1;

__END__

=head1 NAME

XML::Feed::JavaScript - Serialize XML feeds as JavaScript

=head1 SYNOPSIS

  use XML::Feed::JavaScript;

  my $feed = XML::Feedi::JavaScript->parse(URI->new('http://example.com/atom.xml'))
         or die XML::Feed::JavaScript->errstr;
  print $feed->as_javascript;

=head1 DESCRIPTION

XML::Feed::JavaScript allows you to serialize XML feeds as JavaScript by using XML::Feed syndication feed parser for both RSS and Atom feeds. 

XML::Feed::JavaScript supports Perl version 5.6.1 or later.

=head1 METHODS

=head2 as_javascript ( [I<$opt>] )

  print $feed->as_javascript({
      max      => $max,
      encoding => $encoding,
      tmpl_opt => {
          filename => $filename,
          die_on_bad_params => 0,
      },
  });

=over 4

=item * max

Limit the maximum of entries.

=item * encoding

Pass in the encoding you wish to get JavaScript by. If not passed in, default value 'utf8' will be set. See the documentation of L<Encode> for more detail.

=item * tmpl_opt

Set the options for HTML::Template, but as hashref. See the documentation of L<HTML::Template> for more detail.

=back

=head2 save_javascript ( I<filename>, [I<$opt>] )

Pass in the filename you wish to save your JavaScript in. Optionally you can pass in I<$opt> in the same manner as I<as_javascript()> above.

=head1 SEE ALSO

=over 4

=item * L<XML::Feed>

=item * L<Encode>

=item * L<Encode::compat>

=item * L<HTML::Template>

=back

=head1 AUTHOR

Kentaro Kuribayashi, E<lt>kentarok@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Kentaro Kuribayashi

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
