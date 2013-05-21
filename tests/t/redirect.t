# libquvi-scripts
# Copyright (C) 2011  Toni Gundogdu <legatvs@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.

use warnings;
use strict;

use Test::More;

eval "use JSON::XS";
plan skip_all => "JSON::XS required for testing" if $@;

eval "use Test::Deep";
plan skip_all => "Test::Deep required for testing" if $@;

use Test::Quvi;

my $q = Test::Quvi->new;

plan skip_all => "TEST_SKIP rule"
  if $q->test_skip("redirect");

plan tests => 14;

my $j = $q->get_json_obj;

test_redirect_url(    # Test self.redirect_url in academicearth.lua
       "http://www.academicearth.org/lectures/intro-roman-architecture",
       "data/resolve/redirect_url_academicearth.json"
                 );

=for comment
test_redirect_url(    # Test self.redirect_url in collegehumor.lua
  "http://www.dorkly.com/embed/17349/ridiculous-way-to-get-ammo-to-teammates-in-battlefield-bad-company-2",
  "data/resolve/redirect_url_dorkly.json"
                 );
=cut

test_redirect_url(    # Test self.redirect_url in ted.lua
      "http://www.ted.com/talks/paul_lewis_crowdsourcing_the_news.html",
      "data/resolve/redirect_url_ted.json"
                 );

test_redirect_url(    # Test (one of three) self.redirect_url in tcmag.lua
      "http://www.tcmag.com/magazine/traffic_in_ho_chi_minh_city_time_lapse/",
      "data/resolve/redirect_url_tcmag.json"
                 );

test_redirect_url(    # Test self.redirect_url in bikeradar.lua
      "http://www.bikeradar.com/videos/giant-defy-advanced-2-road-bike-of-the-year-2013-winner-Vy3za54p50D2U?side=choice",
      "data/resolve/redirect_url_bikeradar.json"
                 );

test_redirect_url(    # Test self.redirect_url in 101greatgoals.lua
      "http://www.101greatgoals.com/gvideos/golazo-eliaquim-mangalas-showboat-backheel-porto-v-nacional/",
      "data/resolve/redirect_url_101greatgoals.json"
                 );

test_redirect_url(    # Test self.redirect_url in liveleak.lua
      "http://www.liveleak.com/view?i=fff_1368950004",
      "data/resolve/redirect_url_liveleak.json"
                 );

test_url_shortener(    # Test URL shortener support
        "http://is.gd/WipJlL",             # -> http://vimeo.com/42605731
        "data/format/default/vimeo.json"
                  );

sub test_redirect_url
{
  my ($url, $json) = @_;
  my ($r, $o) = $q->run($url, "-vq");
  is($r, 0, "quvi exit status == 0") or diag $url;
SKIP:
  {
    skip 'quvi exit status != 0', 1 if $r != 0;
    my $e = $q->read_json($json, 1)
      ;    # 1=prepend --data-root (if specified in cmdline)
    cmp_deeply($j->decode($o), $e, "compare with $json")
      or diag $url;
  }
}

sub test_url_shortener
{
  my ($url, $json) = @_;
  my ($r, $o) = $q->run($url, "-vq");
  is($r, 0, "quvi exit status == 0") or diag $url;
SKIP:
  {
    skip 'quvi exit status != 0', 1 if $r != 0;
    my $e = $q->read_json($json, 1)
      ;    # 1=prepend --data-root (if specified in cmdline)
    cmp_deeply($j->decode($o), $e, "compare with $json")
      or diag $url;
  }
}

# vim: set ts=2 sw=2 tw=72 expandtab:
