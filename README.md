# sonarcloud-ruby-template
**Updated: 2022/01/06**

This repository demonstrates how you can automatically integrate Rubocop and Rspec/Simplecov with SonarCloud/SonarQube
using Github Actions.

## Prerequisites
Before you can use Github Actions with SonarCloud/SonarQube you first have to perform the necessary setup.  
The steps consists of the following:

1. Importing/Setting up the project in SonarCloud/SonarQube
2. Defining SONAR_TOKEN in the repository secrets

Please refer to the SonarCloud documentation for how to set this up:
https://docs.sonarcloud.io/advanced-setup/ci-based-analysis/github-actions-for-sonarcloud/

## Repository Structure

The repository primarily consists of the following files:

* [.github/workflows/build.yml](.github/workflows/build.yml)
  * The Github action's workflow file
* [.rspec](.rspec)
  * rspec config file
    * Necessary for running SimpleCov (through the spec helper)
* [spec/spec_helper.rb](spec/spec_helper.rb)
  * Contains necessary setup code for the unit tests
* [sonar-project.properties](sonar-project.properties)
  * SonarCloud/SonarQube config file

## Sample output
Please refer to the Pull Request section for sample output from SonarCloud.

## Configuring SonarCloud/SonarQube
SonarCloud/SonarQube requires to be configured in order to work.
These configurations are stored inside [sonar-project.properties](sonar-project.properties), please refer to it for a 
complete example.

### Project related settings
To set the right project the below keys are set:
```
sonar.projectKey={PROJECT KEY}
sonar.organization={ORGANIZATION KEY}
```
`{PROJECT KEY}` refers to the unique Sonar project key. As of this writing, this can be found under the organizations
Administration:  
`Administration > Project Management` (The `Key` column for the respective project)

`{ORGANIZATION KEY}` refers to the unique organization key in SonarCloud/SonarQube, this can be found on most
organization page's URL. More specifically the part after organization:  
`https://sonarcloud.io/organizations/{ORGANIZATION KEY}/projects`

### Rubocop related settings
SonarCloud/SonarQube retrieves data from Rubocop by reading a JSON file containing the execution result of Rubocop.
How to set this up is explained in the `3. Running rubocop` section.

It is necessary to specify the path to this JSON file, which is done by defining the following setting:  
`sonar.ruby.rubocop.reportPaths={path to json file}`

The path is relative to the repository root, so if the file is located in the root 
directory it should be defined as follows (Assuming the file name is rubocop.json):
`sonar.ruby.rubocop.reportPaths=rubocop.json`

### Test coverage related settings
SonarCloud/SonarQube retrieves data from SimpleCov by reading a JSON file containing the execution result of SimpleCov.  
How to set this up is explained in the `4.1 Setting up JSON output for SimpleCov` section.

It is necessary to specify the path to this JSON file, which is done by defining the following setting 
(`coverage/coverage.json` is the default output path):  
`sonar.ruby.coverage.reportPaths=coverage/coverage.json`

#### Excluding unit tests from the SonarCloud/SonarQube Coverage calculation
For SonarCloud/SonarQube to correctly calculate the test coverage, it may be necessary to exclude the unit test directory,
this can be done by defining the following setting (assuming the directory is `spec`):
`sonar.coverage.exclusions=spec/**`

## Setting up the Github Action
In order to trigger the SonarCloud/SonarQube Code Analysis you need to create a workflow yaml file.
For a complete example view the [workflow yaml file included in this repository](.github/workflows/build.yml).

In the following sections, we will go through each part of the file (excluding the general structure).

### 1. Repository checkout
The first step checks out the repository so that the necessary files are available.
```yaml
- uses: actions/checkout@v3
    with:
      fetch-depth: 0  # Shallow clones should be disabled for a better relevancy of analysis
```

### 2. Setting up Ruby
The following two steps set up Ruby and install the necessary dependencies.
```yaml
- name: Set up Ruby
  uses: ruby/setup-ruby@359bebbc29cbe6c87da6bc9ea3bc930432750108
  with:
    ruby-version: '3.1'
    bundler-cache: true 
- name: Install dependencies
  run: bundle install
```
### 3. Running rubocop
The following step runs Rubocop and outputs the result to stdout, as well as to a JSON file called rubocop.json.  
This is necessary for sharing the data with SonarCloud/SonarQube, as this is how it retrieves the data from Rubocop.
```yaml
- name: Run Rubocop
  continue-on-error: true # Run even if previous step fails
  run: bundle exec rubocop --format progress --format json --out rubocop.json 
```
`continue-on-error` is defined to prevent the execution from being halted by Rubocop due to Rubocop finding invalid code.

### 4. Running unit tests and generating test coverage
The following step executes the unit tests and generates test coverage.
```yaml
- name: Run rpsec
  run: bundle exec rspec
```
#### 4.1 Setting up JSON output for SimpleCov
SimpleCov doesn't output the coverage result in JSON by default, so it's necessary to configure it to do so.  
In this case, this configuration is contained in the spec helper. The following configuration makes SimpleCov output the
test coverage in both JSON and HTML.  
For this to work you need to install the `simplecov_json_formatter` first, as it's not included by default.

```ruby
require 'simplecov'
require 'simplecov_json_formatter'

# Generate HTML and JSON reports
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])
```

### 5. Fixing coverage paths
As of this writing, there is a problem with the file paths outputted by SonarCloud/SonarQube on Github Actions that makes
SonarCloud/SonarQube unable to find the files. This step corrects the paths so the files can be found.
```yaml
- name: Fix code coverage paths
        working-directory: ./coverage
        run: | # The SimpleCov paths needs to be fixed for SonarCloud to be able to find them: https://stackoverflow.com/a/74279849
          sed -i 's@'$GITHUB_WORKSPACE'@/github/workspace/@g' coverage.json
```

### 6. Running SonarCloud/SonarQube
The last step runs the Code Analysis.
```yaml
- name: SonarCloud Scan
  uses: SonarSource/sonarcloud-github-action@master
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # Needed to get PR information, if any
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```