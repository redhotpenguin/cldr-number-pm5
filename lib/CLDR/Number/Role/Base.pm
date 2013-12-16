package CLDR::Number::Role::Base;

use utf8;
use Carp;
use CLDR::Number::Data::Base;
use Moo::Role;

# This role does not have a publicly supported interface and may change in
# backward incompatible ways in the future. Please use one of the documented
# classes instead.

our $VERSION = '0.00_02';

requires qw( BUILD );

has version => (
    is      => 'ro',
    default => $VERSION,
);

has cldr_version => (
    is      => 'ro',
    default => 24,
);

has locale => (
    is      => 'rw',
    trigger => 1,
);

has default_locale => (
    is     => 'ro',
    coerce => sub {
        my ($locale) = @_;

        if (!defined $locale) {
            carp 'default_locale is not defined';
        }
        elsif (!exists $CLDR::Number::Data::Base::DATA->{$locale}) {
            carp "default_locale '$locale' is unknown";
        }
        else {
            return $locale;
        }

        return;
    },
);

# TODO: length NYI
has length => (
    is => 'rw',
);

has decimal_sign => (
    is => 'rw',
);

has group_sign => (
    is => 'rw',
);

has plus_sign => (
    is => 'rw',
);

has minus_sign => (
    is => 'rw',
);

has _locale_inheritance => (
    is      => 'rw',
    default => sub { [] },
);

has _init_args => (
    is => 'rw',
);

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;

    return $class->$orig(@args) if @args % 2;
    return $class->$orig(@args, _init_args => {@args});
};

before BUILD => sub {
    my ($self) = @_;

    return if $self->_has_init_arg('locale');

    $self->_trigger_locale;
};

after BUILD => sub {
    my ($self) = @_;

    $self->_init_args({});
};

sub _has_init_arg {
    my ($self, $arg) = @_;

    return unless $self->_init_args;
    return exists $self->_init_args->{$arg};
}

sub _set_unless_init_arg {
    my ($self, $attribute, $value) = @_;

    return if $self->_has_init_arg($attribute);

    $self->$attribute($value);
}

sub _clear_unless_init_arg {
    my ($self, $attribute) = @_;

    return if $self->_has_init_arg($attribute);

    my $clearer = "clear_$attribute";
    $self->$clearer;
}

sub _build_signs {
    my ($self, @signs) = @_;

    for my $sign (@signs) {
        my $attribute = $sign;

        next if $self->_has_init_arg($attribute);

        $sign =~ s{ _sign $ }{}x;

        $self->$attribute($self->_get_data(symbols => $sign));
    }
}

sub _trigger_locale {
    my ($self, $locale) = @_;
    my ($lang, $script, $region, $ext) = _split_locale($locale);

    if ($lang && exists $CLDR::Number::Data::Base::DATA->{$lang}) {
        $self->_locale_inheritance(
            _build_inheritance($lang, $script, $region, $ext)
        );
        $locale = $self->_locale_inheritance->[0];
    }
    elsif ($self->default_locale) {
        $locale = $self->default_locale;
        $self->_locale_inheritance(
            _build_inheritance( _split_locale($locale) )
        );
    }
    else {
        $locale = 'root';
        $self->_locale_inheritance( [$locale] );
    }

    $self->{locale} = $locale;

    $self->_build_signs(qw{ decimal_sign group_sign plus_sign minus_sign });
}

sub _split_locale {
    my ($locale) = @_;

    return unless defined $locale;

    $locale = lc $locale;
    $locale =~ tr{_}{-};

    my ($lang, $script, $region, $ext) = $locale =~ m{ ^
              ( [a-z]{2,3}          )     # language
        (?: - ( [a-z]{4}            ) )?  # script
        (?: - ( [a-z]{2} | [0-9]{3} ) )?  # country or region
        (?: - ( u- .+               ) )?  # extension
            -?                            # trailing separator
    $ }xi;

    $script = ucfirst $script if $script;
    $region = uc      $region if $region;

    return $lang, $script, $region, $ext;
}

sub _build_inheritance {
    my ($lang, $script, $region, $ext) = @_;
    my @tree;

    for my $subtags (
        [$lang, $region, $ext],
        [$lang, $script, $region],
        [$lang, $script],
        [$lang, $region],
        [$lang],
    ) {
        next if grep { !$_ } @$subtags;
        my $locale = join '-', @$subtags;
        next if !exists $CLDR::Number::Data::Base::DATA->{$locale};
        push @tree, $locale;
    }
    push @tree, 'root';

    return \@tree;
}

sub _get_data {
    my ($self, $type, $key) = @_;
    my $data = $CLDR::Number::Data::Base::DATA;

    for my $locale (@{$self->_locale_inheritance}) {
        return $data->{$locale}{$type}{$key}
            if exists $data->{$locale}
            && exists $data->{$locale}{$type}
            && exists $data->{$locale}{$type}{$key};
    }

    return undef;
}

1;
