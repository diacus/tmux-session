#!/usr/bin/perl -w

use strict;

use File::Path qw(make_path);
use YAML::Tiny;

my $settingsPath = "$ENV{HOME}/.config/tmux-session.yml";

sub main
{
  my $settings = loadSessionSettings();
  my $sessionName;
  my $session;

  return handleNoSettings() unless (defined $settings);

  $sessionName = shift;
  $session = getSession($settings, $sessionName);

  setUp($session) unless (isSetUp($session));
  attach($session);

  return 0;
}

sub setUp
{
  my $session = shift;

  my @windows;
  my @rc;

  make_path($session->{home}) unless (-e $session->{home});
  chdir($session->{home});

  @rc = @{$session->{rc}} if (exists $session->{rc});

  foreach my $command (@rc) {
    system($command);
  }

  system("tmux -2 new -s '$session->{name}' -d");

  @windows = @{$session->{windows}} if (exists $session->{windows});

  while (my ($i, $window) = each @windows) {
    system("tmux new-window -t $session->{name}") if ($i > 0);
    $window->{id} = "$session->{name}:$i";
    windowSetUp($window);
  }

  system("tmux select-window -t $session->{name}:0");
}

sub windowSetUp
{
  my $window = shift;
  my $layout = $window->{layout} || 'tiled';

  my @panes;
  my @rc;

  @panes = @{$window->{panes}} if (exists $window->{panes});
  @rc    = @{$window->{rc}}    if (exists $window->{rc});

  foreach (@panes[1 .. $#panes]) {
    system("tmux split-window -t $window->{id}");
  }

  system("tmux select-layout -t $window->{id} $layout");

  if (@rc) {
    system("tmux set-window-option -t $window->{id} synchronize-panes");
    tmuxRun($window->{id}, @rc);
    system("tmux set-window-option -u -t $window->{id} synchronize-panes");
  }

  while (my ($id, $pane) = each @panes) {
    $pane->{id} = $id;
    paneSetUp($pane);
  }

  system("tmux select-pane -t 0");
  system("tmux rename-window -t $window->{id} $window->{name}");
}

sub paneSetUp
{
  my $pane = shift;
  my @rc;

  @rc = @{$pane->{rc}} if (exists $pane->{rc});
  return unless (@rc);

  system("tmux select-pane -t $pane->{id}");
  tmuxRun(undef, @rc);
}

sub tmuxRun
{
  my ($target, @commands) = @_;
  my $targetFlag = defined $target ? "-t $target" : "";

  foreach my $command (@commands) {
    system("tmux send-keys $targetFlag '$command' Enter");
  }
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

  open(TMUX, 'tmux ls 2>/dev/null |');

  while (<TMUX>) {
    my ($name, @__) = split(/:/);
    $exists++ if ($name eq $session->{name});
  }

  close(TMUX);

  return $exists > 0;
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

sub attach
{
  my $session = shift;
  system("tmux -2 attach -t $session->{name}");
}

exit main(@ARGV);
