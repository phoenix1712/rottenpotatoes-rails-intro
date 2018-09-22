class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if params[:sort].nil? && params[:ratings].nil? &&
        (!session[:sort].nil? || !session[:ratings].nil?)
      redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings])
    end
    
    @sort_by = params[:sort]
    @ratings = params[:ratings] 
    if @ratings.nil?
      ratings = Movie.ratings 
    else
      ratings = @ratings.keys
    end
    
    @all_ratings = Movie.ratings.inject(Hash.new) do |all_ratings, rating|
          all_ratings[rating] = @ratings.nil? ? true : @ratings.has_key?(rating) 
          all_ratings
    end
    
    if !@sort_by.nil?
      begin
        @movies = Movie.where('rating in (?)', ratings).order("#{@sort_by} ASC")
      rescue ActiveRecord::StatementInvalid
        flash[:warning] = "Movies cannot be sorted by #{@sort_by}."
        @movies = Movie.where('rating in (?)', ratings)
      end
    else
      @movies = Movie.where('rating in (?)', ratings)
    end
    
    session[:sort] = @sort_by
    session[:ratings] = @ratings
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
