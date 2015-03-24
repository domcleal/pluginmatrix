require 'sinatra'
require 'json'
require 'octokit'
require 'gems'
require 'base64'

def get_rubygems(name, compare = '>= 0')
  gemcmp = Gem::Dependency.new('', compare)
  newest = Gems.versions(name).find_all { |v| gemcmp.match?('', v['number']) }.map { |v| Gem::Version.new v['number'] }.max
  newest ? newest.version : nil
end

def get_octokit
  if ENV['GITHUB_OAUTH_TOKEN']
    Octokit::Client.new(access_token: ENV['GITHUB_OAUTH_TOKEN'])
  else
    Octokit::Client.new
  end
end

def show_badge(badge_name, gem_name, pkg_gem_version, compare)
  colour = 'blue'
  unless compare.nil?
    gem_version = get_rubygems(gem_name, compare)
    colour = (gem_version && pkg_gem_version >= gem_version) ? 'green' : 'yellow'
  end
  redirect "https://img.shields.io/badge/#{badge_name}-#{pkg_gem_version}-#{colour}.svg"
end

get '/gem/:name' do
  version = if params[:compare]
              get_rubygems(params[:name], params[:compare])
            else
              get_rubygems(params[:name])
            end

  if version
    redirect "https://img.shields.io/badge/gem-#{version}-green.svg"
  else
    redirect 'https://img.shields.io/badge/gem-not%20found-red.svg'
  end
end

get '/deb/:repo/:name' do
  halt 'invalid repo' unless params[:repo] =~ /\A([\d\.]+|develop)\z/
  halt 'invalid name' unless params[:name] =~ /\A[\w-]+\z/
  package = 'ruby-' + params[:name].gsub('_', '-')

  begin
    bundler = get_octokit.contents('theforeman/foreman-packaging', ref: "deb/#{params[:repo]}", path: "plugins/#{package}/#{params[:name]}.rb")
  rescue Octokit::NotFound
    redirect 'https://img.shields.io/badge/deb-missing-red.svg'
  end
  bundler = Base64.decode64(bundler[:content])

  if bundler =~ /\Agem\s+['"]([\w-]+)['"],\s+['"]([\w\.-]+)['"]/
    gem_name, pkg_gem_version = $1, $2
  else
    halt 'cannot determine gem version from packaging repo'
  end

  show_badge('deb', gem_name, pkg_gem_version, params[:compare])
end

get '/rpm/:repo/:name' do
  halt 'invalid repo' unless params[:repo] =~ /\A([\d\.]+|develop)\z/
  halt 'invalid name' unless params[:name] =~ /\A[\w-]+\z/
  package = 'rubygem-' + params[:name]

  begin
    files = get_octokit.contents('theforeman/foreman-packaging', ref: "rpm/#{params[:repo]}", path: package)
  rescue Octokit::NotFound
    redirect 'https://img.shields.io/badge/rpm-missing-red.svg'
  end

  filename = files.map { |f| f['name'] }.find { |f| f.end_with? '.gem' }
  if filename && filename =~ /\A(#{params[:name]})-([\w\.-]+)\.gem\Z/
    gem_name, pkg_gem_version = $1, $2
  else
    halt 'cannot determine gem version from packaging repo'
  end

  show_badge('rpm', gem_name, pkg_gem_version, params[:compare])
end

get '/' do
  locals = {'matrix' => YAML.load(File.read(File.expand_path('../matrix.yaml', __FILE__)))}
  erb :matrix, locals: locals
end
