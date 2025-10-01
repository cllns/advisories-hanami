# Advisories (Hanami)

**Experimental rewrite** of the [ecosyste-ms/advisories](https://github.com/ecosyste-ms/advisories) Rails application using [Hanami 2.2](https://hanamirb.org/).

## About

This is an experimental port of the Advisories service from Rails to Hanami. The original Rails application provides security vulnerability metadata for many open source software ecosystems through a comprehensive API.

**Original Rails application:** https://github.com/ecosyste-ms/advisories
**Production site:** https://advisories.ecosyste.ms/

## Key Technologies

- **[Hanami 2.2](https://hanamirb.org/)** - Ruby web framework
- **[hanami-sprockets](https://github.com/andrew/hanami-sprockets)** - Asset pipeline for Hanami using Sprockets (experimental)
- **PostgreSQL** - Database
- **Bootstrap 5** - CSS framework

## Asset Pipeline

This project uses [hanami-sprockets](https://github.com/andrew/hanami-sprockets), an experimental gem that brings Sprockets asset pipeline support to Hanami, eliminating the need for Node.js/npm. It provides:

- Automatic asset compilation (SCSS, JavaScript, images)
- Asset fingerprinting and caching
- Automatic gem asset path discovery (enables `@import "bootstrap"` without configuration)
- Development middleware for live asset serving

## Development

### Prerequisites

- Ruby 3.4.5
- PostgreSQL
- Bundler

### Setup

```bash
# Install dependencies
bundle install

# Setup database
bundle exec hanami db create
bundle exec hanami db migrate

# Start the development server
bundle exec hanami server
```

Visit http://localhost:2300

### Running Tests

```bash
bundle exec rspec
```

## Status

This is an **experimental project** exploring Hanami 2.2 capabilities and asset pipeline alternatives. It is not intended for production use.

## License

Same as the original project:
- Code: [AGPL-3.0](LICENSE)
- Data: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
