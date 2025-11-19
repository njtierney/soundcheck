# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Project

This is a shiny app that facilitates data validation it allows the user to upload a piece of data, have it display as a data table (DT), and have the ability to add a checkbox on a given data cell, which then opens a note prompt, so that people can to input validation checking on data.

## Key development commands

General advice:
* When running R from the console, always run it with `--quiet --vanilla`
* Always run `air format .` after generating code
* Always make changes to R code for ui.R and server.R in R/ui.R and R/server.R

### Testing

- DO NOT USE `devtools::test_active_file()`
- All testing functions automatically load code; you don't needs to.


### Documentation to read

You should read:

- https://mastering-shiny.org/

## Core Architecture

### File Organization

- `R/` - All R source code, organized by functionality