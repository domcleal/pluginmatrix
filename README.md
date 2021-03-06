# Foreman plugin matrix

Shows versions of Foreman plugins in rubygems.org, our apt and yum repositories (well, our source control for them at any rate) by way of badges.

## API

### GET /

Web page listing matrix of plugins from `matrix.yaml`.

### GET /gem/:name

Examples:

* `/gem/foreman-tasks`
* `/gem/foreman-tasks?compare=~%3E0.5.0`

Gets the latest version from rubygems.org, optionally matching a gem version specification (`%3E` is `>`).

### GET /deb/:repo/:name

Examples:

* `/deb/develop/foreman-tasks`
* `/deb/1.8/foreman-tasks?compare=~%3E0.6.0`

Gets the latest Debian package version for a given gem, optionally comparing against a gem version specification (`%3E` is `>`).

### GET /rpm/:repo/:name

Examples:

* `/rpm/develop/foreman-tasks`
* `/rpm/1.8/foreman-tasks?compare=~%3E0.6.0`

Gets the latest RPM package version for a given gem, optionally comparing against a gem version specification (`%3E` is `>`).

## Copyright

Copyright (c) 2015 Dominic Cleal

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
