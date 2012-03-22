# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create(movie)
  end
  #assert false, "Unimplmemented"
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page


# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following rating checkboxes: (.*)/ do |uncheck, rating_list|
  
  if uncheck.eql?(nil)
    rating_list.split(',').each {|field| field.tr!(' ',''); check("ratings_#{field}")}
  else
    rating_list.split(',').each {|field| field.tr!(' ',''); uncheck("ratings_#{field}")}
  end
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
end

Given /^I (un)?check all ratings for the movies$/ do |process|
  ratings = Movie.all(:select => 'DISTINCT rating')
  if process.eql?(nil)
    ratings.map {|el| check("ratings_#{el.rating}")}
  else
    ratings.map {|el| uncheck("ratings_#{el.rating}")}
  end
end

When /^I select to sort movies by (.*)$/ do |sort_method|
  sort_method = sort_method.tr(' ','_')
  if ['title','release_date'].include?(sort_method)
    click_link "#{sort_method}_header"
  else
    raise StandardError
  end
end



When /^I submit the (ratings) filter$/ do |button|
  click_button("#{button}_submit")
end


Then /^I should see (.*) rated movies$/ do |ratings|
  within_table('movies') do
    has_css?("td").should be_true
    all(:css,"td:nth-child(2)").each do |node|
      ratings.split(',').collect!{|rating| rating.tr(' ','')}.include?(node.text).should be_true
    end

  end
end

Then /^I shouldn't see (.*) rated movies$/ do |ratings|
  within_table('movies') do
    all(:css,"td:nth-child(2)").each do |node|
      ratings.split(',').collect! {|rating| rating.tr(' ','')}.include?(node.text).should_not be_true
    end
  end
end

Then /^I should see ([\w\s]*)? movies$/ do |how_many|
  within_table('movies') do
    if how_many.eql?("all of the")
      all(:css,"tbody>tr").count.should == Movie.count
    elsif how_many.eql?("no")
      all(:css,"tbody>tr").count.should == 0
    end
  end
end

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  page.body.should match(/.*#{e1}.*#{e2}/m) 
  #assert false, "Unimplmemented"
end

Then /^I should not see "([^"]*)" before "([^"]*)"$/ do |arg1, arg2|
  page.body.should_not match(/(.*#{arg1}).*(#{arg2})/m) 
end
