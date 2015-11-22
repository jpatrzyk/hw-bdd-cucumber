# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(movie);
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  pattern = Regexp.new(".*movies.*" + e1 + ".*" + e2 + ".*" + "</table>", Regexp::MULTILINE)
  expect(page.body).to match(pattern)
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |should_uncheck, rating_list|
  ratings = rating_list.split(',')
  ratings.each do |rating|
    checkbox = "ratings[#{rating.strip}]"
    should_uncheck.to_s.strip.length == 0 ? check(checkbox) : uncheck(checkbox)
  end
end

Then /I should see only the movies with following ratings: (.*)/ do |rating_list|
  ratings = rating_list.split(%r{\s*,\s*})
  ratings_elements = page.all(:css, '#movies td').select.with_index { |_, i| i % 4 == 1 }
  actual_ratings = ratings_elements.map { |elem| elem.text }.uniq
  expect(actual_ratings).to match_array(ratings)
end

Then /I should see all the movies/ do
  page.all('#movies tr').count.should == Movie.count + 1
end
