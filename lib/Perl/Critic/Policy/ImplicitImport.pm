use strict;
use warnings;
package Perl::Critic::Policy::ImplicitImport;

use Perl::Critic::Utils qw($SEVERITY_LOW);
use parent 'Perl::Critic::Policy';

our $VERSION = '0.000001';

use constant DESC => 'Using a module without an explicit import list';
use constant EXPL =>
    'Using the a module without specifying an import list can result in importing many symbols. Import the functions or constants you want explicitly, or prevent the import with ().';

sub applies_to       { 'PPI::Statement::Include' }
sub default_severity { $SEVERITY_LOW }

sub supported_parameters {
    return (
        {
            name        => 'ignored_modules',
            description => 'Modules which will be ignored by this policy.',
            behavior    => 'string list',
            list_always_present_values => [
                qw(
                    Carp::Always
                    Courriel::Builder
                    Data::Dumper
                    Data::Dumper::Concise
                    Data::Printer
                    DDP
                    Exporter::Lite
                    File::chdir
                    Git::Sub
                    HTTP::Message::PSGI
                    Import::Into
                    Mojolicious::Lite
                    Moo
                    Moo::Role
                    Moose
                    Moose::Exporter
                    Moose::Role
                    Moose::Util::TypeConstraints
                    MooseX::LazyRequire
                    MooseX::NonMoose
                    MooseX::Role::Parameterized
                    MooseX::SemiAffordanceAccessor
                    Mouse
                    Test2::V0
                    Test::Class::Moose
                    Test::Class::Moose::Role
                    Test::More
                    )
            ],
        },
    );
}

sub violates {
    my ( $self, $elem ) = @_;
    my $ignore = $self->{_ignored_modules};

    if (
           ( $elem->type // q{} ) eq 'use'
        && ( $elem->module // q{} ) =~ m{[A-Z]}    # don't flag pragmas
        && !$elem->arguments
        && !exists $ignore->{ ( $elem->module // q{} ) }
    ) {
        return $self->violation( DESC, EXPL, $elem );
    }

    return ();
}

1;

# ABSTRACT: Prefer subroutine imports to be explicit
