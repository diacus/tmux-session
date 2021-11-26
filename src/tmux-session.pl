#!/usr/bin/perl -w

use strict;

use File::Path qw(make_path);
use Getopt::Long;
use YAML::Tiny;
use Data::Dumper;

my $settingsPath = "$ENV{HOME}/.config/tmux-session.yml";

sub main
{
  my $settings = loadSessionSettings();
  my $sessionName;
  my $session;

  return handleNoSettings() unless (defined $settings);

  $sessionName = shift;
  $session = getSession($settings, $sessionName);

  setUp($session) unless(isSetUp($session));
  attach($session);

  return 0;
}

sub handleNoSettings
{
  print STDERR "No settings found\n";
  print STDERR "Write session settings in $settingsPath using YAML format\n";

  return 1;
}

sub loadSessionSettings
{
  my $settingsPath = "$ENV{HOME}/.config/tmux-session.yml";
  my $settings;

  if (-e $settingsPath) {
    $settings = YAML::Tiny->read($settingsPath)->[0];
  }

  return $settings;
}

sub getSession
{
  my ($settings, $sessionName) = @_;
  my $session;
  my $type;
  my $instance;

  $sessionName =~ /(\S+)-(\S+)/;
  $type = lc $1;
  $instance = lc $2;

  $session = $settings->{sessions}->{$type};
  $session->{home} = qq($settings->{home}/$type/$instance);
  $session->{name} = uc $sessionName;

  return $session;
}

sub isSetUp
{
  my $session = shift;
  my $exists = 0;

  open(TMUX, 'tmux ls |');

  while (<TMUX>) {
    my ($name, @__) = split(/:/);
    $exists++ if ($name eq $session->{name});
  }

  close(TMUX);

  return $exists > 0;
}

sub setUp
{
  my $session = shift;
  my @windows = @{$session->{windows}};

  make_path($session->{home}) unless (-e $session->{home});
  chdir($session->{home});

  system("tmux -2 new -s '$session->{name}' -d");

  while (my ($i, $window) = each @windows) {
    my @rc = @{$window->{rc}};
    my $id = "$session->{name}:$i";

    system("tmux new-window -t $session->{name}") if ($i > 0);

    foreach my $command (@rc) {
      system("tmux send-keys -t $id '$command' Enter");
    }

    system("tmux rename-window -t $id $window->{name}");
  }

  system("tmux select-window -t $session->{name}:0");
}

sub attach
{
  my $session = shift;
  system("tmux -2 attach -t $session->{name}");
}

exit main(@ARGV);
