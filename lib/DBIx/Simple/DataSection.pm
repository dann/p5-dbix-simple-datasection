package DBIx::Simple::DataSection;
use strict;
use warnings;
use base 'DBIx::Simple';
our $VERSION = '0.01';

# not tested yet!!!
# I'll test this module this week :)

use Carp;
use Data::Section::Simple;

sub new {
    my $self = shift->SUPER::new(@_);
    $self->{package} ||= scalar caller;
    $self->{section} = Data::Section::Simple->new( $self->{package} );
    $self->{cache} = {};
    $self;
}

# other name?
sub query_by_sql {
    my ( $self, $sql_name, @binds ) = @_;
    my $query = $self->get_sql($sql_name);
    $self->SUPER::query( $query, @binds );
}

sub get_sql {
    my ( $self, $sql_name ) = @_;

    if ( my $sql = $self->{cache}{$sql_name} ) {
        return $sql;
    }
    my $sql = $self->{section}->get_data_section($sql_name);
    if ($sql) {
        $self->{cache}{$sql_name} = $sql if $self->{use_cache};
        return $sql;
    }
    croak "could not find sql: $sql_name in __DATA__ section";
}

1;

__END__

=encoding utf-8

=head1 NAME

DBIx::Simple::DataSection - 

=head1 SYNOPSIS

  use DBIx::Simple::DataSection; 
  my $db = DBIx::Simple::DataSection->connect('dbi:SQLite:dbname=../db/hoge.db')
    or die DBIx::Simple::DataSection->error;

  my $rs = $db->query_by_sql('select.sql', $foo, $bar) 
    or die $db->error;
  
  __DATA__
  @@ select.sql 
  SELECT FROM foo WHERE foo = ? OR bar = ?

=head1 DESCRIPTION

DBIx::Simple::DataSection is

=head1 SOURCE AVAILABILITY

This source is in Github:

  http://github.com/dann/

=head1 CONTRIBUTORS

Many thanks to:


=head1 AUTHOR

dann E<lt>techmemo@gmail.comE<gt>

=head1 SEE ALSO

L<DBIx::Simple>, L<Data::Section::Simple>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
