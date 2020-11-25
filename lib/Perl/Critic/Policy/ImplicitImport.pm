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
                    FindBin
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

=head1 NAME

Perl::Critic::Policy::ImplicitImport

=head1 DESCRIPTION

Perl modules can implicitly import many symbols (functions and constants) if no imports are specified. To avoid this, and to assist in
finding where functions have been imported from, specify the symbols you want
to import explicitly in the C<use> statement. Alternatively, specify an empty
import list with C<use Foo ()> to avoid importing any symbols, and fully
qualify the functions or constants, such as C<Foo::strftime>.

    use POSIX;                                                         # not ok
    use POSIX ();                                                      # ok
    use POSIX qw(fcntl);                                                 # ok
    use POSIX qw(O_APPEND O_CREAT O_EXCL O_RDONLY O_RDWR O_WRONLY);    # ok

=head1 CONFIGURATION

By default, this policy ignores many modules (like L<Moo> and L<Moose> for
which implicit imports are the expected and desired ways to use them. See the
source of this module for a complete list. If you would like to ignore additional modules, this can be done via configuration:

    [ImplicitImport]
    ignored_modules = Git::Sub Regexp::Common

=head1 ACKNOWLEDGEMENTS

Much of this code and even some documentation has been inspired by and borrowed
directly from L<Perl::Critic::Policy::Freenode::POSIXImports> and
L<Perl::Critic::Policy::TooMuchCode>.
