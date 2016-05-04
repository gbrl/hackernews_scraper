require 'nokogiri'
require 'pp'
require 'open-uri'
require_relative 'color'
require_relative 'post'
require_relative 'comment'

@post = nil

def process_input(argv_input)
  url = argv_input[0]
  puts url
  make_html_file(url)
end

def make_html_file(url)
  open("post.html", "wb") do |file|
    open(url) do |uri|
     file.write(uri.read)
    end
  end
  doc = Nokogiri::HTML(File.open('post.html'))
  parse(doc)
end

def parse(doc)

  # ITEM ID
  item_id = doc.search('.pagetop > a:last-child').map {|link| link['href'] }
  item_id = item_id[1].gsub("%3","").scan(/\d/).join("").to_i

  # URL
  url = "https://news.ycombinator.com/item?id=#{item_id}"

  # TITLE
  title = doc.search('title').inner_text

  # POINTS
  points = doc.search('.subtext > span:first-child').inner_text

  # CREATE POST
  @post = Post.new(title,url,points,item_id)

  # COMMENT USER
  all_comments = doc.search('td.default > span.comment').map { |comment| comment.inner_text.gsub("  ","").gsub("-----","").gsub("\n\nreply\n\n","")}
  all_ages = doc.search('span.age').map { |age| age.inner_text}
  all_user = doc.search('span.comhead > a').map { |user| user.inner_text.gsub("  ","")}

  all_comments.length.times do |i|
    puts "Found a comment"
    @post.add_comment(Comment.new(all_comments[i-1],all_user[i-1],all_ages[i-1]))
  end

  output_comments(@post)
end

def output_comments(post)
  post.comments.each do |comment|
    puts comment.username
    puts comment.age
    puts comment.content
    puts "--------------------------------------------------"
  end
end

process_input(ARGV)

# EXAMPLE URLs
# https://news.ycombinator.com/item?id=7663775
# https://news.ycombinator.com/item?id=7663774