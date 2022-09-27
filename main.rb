# frozen_string_literal: true

require 'tantiny'
index = Tantiny::Index.new('./tantiny') { text :content }

index << { id: 1, content: 'Hello World!' }
index << { id: 2, content: "What's up?" }
index << { id: 3, content: 'Goodbye World!' }

index.transaction do
  index << { id: 11, content: 'Hello World!' }
  index << { id: 22, content: "What's up?" }
  index << { id: 33, content: 'Goodbye World!' }
  index << { id: 44,
             content: 'The knapsack problem is a problem in combinatorial optimization: Given a set of items, each with a weight and a value, determine the number of each item to include in a collection so that the total weight is less than or equal to a given limit and the total value is as large as possible. It derives its name from the problem faced by someone who is constrained by a fixed-size knapsack and must fill it with the most valuable items. The problem often arises in resource allocation where the decision makers have to choose from a set of non-divisible projects or tasks under a fixed budget or time constraint, respectively.' }
end

index.reload

p index.search('world')

# index = Tantiny::Index.new "./tmp/index", exclusive_writer: true do
index = Tantiny::Index.new './tmp/index' do
  id :imdb_id
  facet :category
  string :title
  text :description
  integer :duration
  double :rating
  date :release_date
end

rio_bravo = OpenStruct.new(
  imdb_id: 'tt0053221',
  type: '/western/US',
  title: 'Rio Bravo',
  description: 'A small-town sheriff enlists a drunk, a kid and an old man to help him fight off a ruthless cattle baron.',
  duration: 141,
  rating: 8.0,
  release_date: Date.parse('March 18, 1959')
)

index << rio_bravo

hanabi = {
  imdb_id: 'tt0119250',
  type: '/crime/Japan',
  title: 'Hana-bi',
  description: 'Nishi leaves the police in the face of harrowing personal and professional difficulties. Spiraling into depression, he makes questionable decisions.',
  duration: 103,
  rating: 7.7,
  release_date: Date.parse('December 1, 1998')
}

index << hanabi

brother = {
  imdb_id: 'tt0118767',
  type: '/crime/Russia',
  title: 'Brother',
  description: 'An ex-soldier with a personal honor code enters the family crime business in St. Petersburg, Russia.',
  duration: 99,
  rating: 7.9,
  release_date: Date.parse('December 12, 1997')
}

index << brother
rio_bravo.rating = 10.0
index << rio_bravo

index.transaction do
  index << rio_bravo
  index << hanabi
  index << brother
end
