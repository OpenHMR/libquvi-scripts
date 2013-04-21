-- libquvi-scripts
-- Copyright (C) 2011,2013  Toni Gundogdu <legatvs@gmail.com>
-- Copyright (C) 2010 quvi project
--
-- This file is part of libquvi-scripts <http://quvi.sourceforge.net/>.
--
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU Affero General Public
-- License as published by the Free Software Foundation, either
-- version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General
-- Public License along with this program.  If not, see
-- <http://www.gnu.org/licenses/>.
--

local FunnyOrDie = {} -- Utility functions unique to this script

-- Identify the media script.
function ident(qargs)
  return {
    can_parse_url = FunnyOrDie.can_parse_url(qargs),
    domains = table.concat({'funnyordie.com'}, ',')
  }
end

-- Parse media URL.
function parse(self)
    self.host_id = "funnyordie"
    local page   = quvi.fetch(self.page_url)

    self.title = page:match('"og:title" content="(.-)">')
                    or error ("no match: media title")

    self.id = page:match('key:%s+"(.-)"')
                or error ("no match: media ID")

    self.thumbnail_url = page:match('"og:image" content="(.-)"') or ''

    local formats = FunnyOrDie.iter_formats(page)
    local U       = require 'quvi/util'
    local format  = U.choose_format(self, formats,
                                     FunnyOrDie.choose_best,
                                     FunnyOrDie.choose_default,
                                     FunnyOrDie.to_s)
                        or error("unable to choose format")
    self.url      = {format.url or error('no match: media stream URL')}
    return self
end

--
-- Utility functions
--

function FunnyOrDie.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)
  if t and t.scheme and t.scheme:lower():match('^http$')
       and t.host   and t.host:lower():match('funnyordie%.com$')
       and t.path   and t.path:lower():match('^/videos/%w+')
  then
    return true
  else
    return false
  end
end

function FunnyOrDie.iter_formats(page)
    local t = {}
    for u in page:gmatch('source src="(.-)"') do
        table.insert(t,u)
    end
    table.remove(t,1) -- Remove the first: the URL for segmented videos
    local r = {}
    for _,u in pairs(t) do
        local q,c = u:match('/(%w+)%.(%w+)$')
        table.insert(r, {url=u, quality=q, container=c})
    end
    return r
end

function FunnyOrDie.choose_best(formats)
    return FunnyOrDie.choose_default(formats)
end

function FunnyOrDie.choose_default(formats)
    return formats[1]
end

function FunnyOrDie.to_s(t)
    return string.format("%s_%s", t.container, t.quality)
end

-- vim: set ts=4 sw=4 tw=72 expandtab:
