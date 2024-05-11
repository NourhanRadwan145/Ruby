require 'json'
# Book class
class Book
  attr_reader :title, :author, :isbn

  def initialize(title, author, isbn)
    @title = title
    @author = author
    @isbn = isbn
  end

  def to_hash
    { title: @title, author: @author, isbn: @isbn }
  end
end

# Inventory class
class Inventory
  def initialize(file_path)
    @file_path = file_path
    @books = load_books
  end

  def load_books
    if File.exist?(@file_path)
      File.open(@file_path, 'r') do |file|
        JSON.parse(file.read).map do |book_data|
          Book.new(book_data['title'], book_data['author'], book_data['isbn'])
        end
      end
    else
      []
    end
  end

  def save_books
    File.open(@file_path, 'w') do |file|
      file.write(JSON.pretty_generate(@books.map(&:to_hash)))
    end
  end

  def list_books
    if @books.empty?
      puts "Inventory is empty."
    else
      @books.each_with_index do |book, index|
        puts "#{index + 1}. #{book.title} by #{book.author} (ISBN: #{book.isbn})"
      end
    end
  end

  def add_book(title, author, isbn)
    new_book = Book.new(title, author, isbn)
    @books << new_book
    save_books
    puts "Added: #{title} by #{author} (ISBN: #{isbn})"
  end

  def remove_book(isbn)
    index = @books.find_index { |book| book.isbn == isbn }
    if index
      removed_book = @books.delete_at(index)
      save_books
      puts "Removed: #{removed_book.title} by #{removed_book.author}"
    else
      puts "Book with ISBN #{isbn} not found."
    end
  end
end

# Usage example:
inventory = Inventory.new("books_inventory.json")

# Add books
inventory.add_book("The Great Gatsby", "F. Scott Fitzgerald", "9780743273565")
inventory.add_book("To Kill a Mockingbird", "Harper Lee", "9780061120084")

# List books
inventory.list_books

# Remove a book by ISBN
inventory.remove_book("9780743273565")

# List books after removal
inventory.list_books
