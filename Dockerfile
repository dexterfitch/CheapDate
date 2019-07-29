#Image name : label
FROM ruby:2.6

#How to set up the container
#Dockerfile is a config file for a container
#/usr/src/app is generally a good default
WORKDIR /usr/src/app

#Copy anything needed as a prerequisite to run the application
#In this case, we need to do a bundle install and a rake db:migrate
RUN gem install bundler
COPY Gemfile Gemfile.lock ./
#Then run that command
RUN bundle install

COPY Rakefile ./
COPY config/ ./config
COPY bin/ ./bin

RUN chmod +x ./bin/run.rb
COPY db/ ./db
COPY app/ ./app
RUN rake db:migrate

CMD [ "./bin/run.rb" ]