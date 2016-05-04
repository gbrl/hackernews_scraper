class Comment
  
  attr_accessor :content, :username, :age

  def initialize(content,username,age)
    @content = content
    @username = username
    @age = age
  end

end