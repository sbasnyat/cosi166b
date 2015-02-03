class MovieData

	# constructor, if one parameter is passed, it takes path to the folder containing the movie data,
	# optionally if two arguments are passed, the first is taken as path to folder and second symbol to specify a particular training/test pair 
	def initialize(*args)
		train_test_h = {:u1 => ["u1.base","u1.test"], 
						:u2 => ["u2.base","u2.test"],
						:u3 => ["u3.base","u3.test"],
						:u4 => ["u4.base","u4.test"],
						:u5 => ["u5.base","u5.test"],
						:ua => ["ua.base","ua.test"],
						:ub => ["ub.base","ub.test"] }
		foldername = args[0]

		# @train_umr_h stands for training user movie rating hash and is a hash table that stores each line of data of training set in the form user_id as key and its 
		# value is another hash table with key movie id and value rating
		# @train_mur_h stands for training movie user rating hash and is a hash table that stores each line of data in the training set in the form movie-id as key and its 
		# value is another hash table with key user_id and value rating
		# @test_umr_arr stands for test user movie rating array and is 2D array i.e. an array of arrays in the form [user_id, movie_id, rating] for each line of test data

		if args.length == 1
			train_filename = File.join(foldername,"u.data")
			@test_umr_arr = nil
		else
			train_test_pair = train_test_h[args[1]]
			train_filename = File.join(foldername,train_test_pair[0])
			test_filename = File.join(foldername,train_test_pair[1])
			@test_umr_arr = load_test(test_filename)
		end

		@train_umr_h, @train_mur_h = load_train(train_filename)
	end

	# this method reads the training dataset line by line, stores it in two hash table forms and returns the two hash tables
	def load_train(train_filename)
		train_data = open(train_filename).read
		
		umr_h = Hash.new
		mur_h = Hash.new

		train_data.each_line do |line|
			data = line.split(" ")
			user_id = data[0].to_i
			movie_id = data[1].to_i
			rate = data[2].to_i

			# for a particular key, it checks if it exists, if not creates a new hash table at that key
			if !umr_h.has_key?(user_id)
				umr_h[user_id] = Hash.new
			end

			umr_h [user_id] [movie_id] = rate

			# for a particular key, it checks if it exists, if not creates a new hash table at that key
			if !mur_h.has_key?(movie_id)
				mur_h[movie_id] = Hash.new
			end

			mur_h [movie_id][user_id] = rate
		end

		return umr_h, mur_h
	end

	# this method reads the test dataset and stores each line in a 2D array i.e an array of arrays in the form [user_id, movie_id, rating] and returns it
	def load_test(test_filename)
		test_data = open(test_filename).read
		umr_arr = Array.new
		test_data.each_line do |line|
			data=line.split(" ")
			user_id=data[0].to_i
			movie_id=data[1].to_i
			rate=data[2].to_i
			umr_arr.push([user_id, movie_id, rate])
		end
		return umr_arr
	end

	# this method returns the rating that user u gave movie m in the training set, and 0 if user u did not rate movie m
	def rating(u,m) 

		if @train_umr_h.has_key?(u) && @train_umr_h[u].has_key?(m) 
				return @train_umr_h[u][m]
		else
			return 0
		end

	end

	# this method returns the array of movies that user u has watched and 0 if the user id cannot be found in the dataset
	def movies(u)

		if @train_umr_h.has_key?(u)
			return @train_umr_h[u].keys
		else
			return 0
		end

	end

	# this method returns the array of users that have seen movie m and 0 if the movie id cannot be found in the dataset
	def viewers(m)

		if @train_mur_h.has_key?(m)
			return @train_mur_h[m].keys
		else
			return 0
		end

	end

	# this method returns a floating point number between 1.0 and 5.0 as an estimate of what user u would rate movie m
	# prediction algorithm sees 10 the users who have watched the movie and checks which of them have watched the most 
	# common movies among the first 20 movies watched by the users with user u, and then returns the rating the user gave the movie m 
	def predict(u,m)
		hash=Hash.new
		viewers_m = viewers(m)
		movies_u = movies(u)

		if (viewers_m == 0 || viewers_m.length < 20) && (movies_u == 0 || movies_u.length < 20)
			return 0
		elsif viewers_m == 0 || viewers_m.length < 20 
			sum = 0
			movies(u)[0..29].each do |mov|
				sum += rating(u,mov)
			end
			return sum/20
		else
			ten_viewers=Array.new(viewers_m[0..9])

			ten_viewers.each do |user|
			
				if user!=u && movies(user).length >= 50
					num_common_movies=(movies_u & movies(user)[0..49]).length
					hash[num_common_movies]=user
				end

			end 

		#finds the user out of the viewers who has the maximum number of movies watched in common with our user u and returns the rating that user gave to movie m
			return rating(hash[hash.keys.max],m)
		end

	end

	# runs the predict method on the first something number of ratings in the test set as specified in the parameter and returns a MovieTest object containing the results.
	# If the parameter is omitted, all of the tests will be run.
	def run_test(*args)

		if args.length == 1
			k = args[0]
			ratinglist=Array.new(@test_umr_arr[0...k])
		else
			ratinglist=Array.new(@test_umr_arr)
		end

		# now finds the prediction rating from the predict function and pushes it into the array 
		ratinglist.each do |line|		
  			predicted= predict(line[0],line[1])
			line.push(predicted)
  		end

  		# creates an instance of class MovieTest and passes the ratinglist as parameter	
  		return MovieTest.new(ratinglist)
	end

end


class MovieTest

	# takes ratinglist i.e. an array of arrays with each element in the form [user_id, movie_id, rating, predicted rating]
	# @error is an array whoese elements are the difference between predicted rating and actual rating for each element on the ratinglist 
	def initialize(ratinglist)
		@ratinglist=ratinglist
		@error=find_error
		@length=ratinglist.length
	end	

	# this method goes through each element of the rating list i.e. each array and finds the difference between the actual and 
	# predicted rating for each and stores the value in an array and returns it
	def find_error
		error=[]

			@ratinglist.each do |result|
				error.push((result[2]-result[3]).abs)
			end

		return error
	end	


	# this method returns the average predication error
	def mean
		summ = @error.inject(0) {|sum, i|  sum + i }
		return (summ.to_f/@length)
	end

	# this method returns the standard deviation of the error
	def stddev
		mean_ = mean
		sum=0

		@error.each do |error|
			sum += ((error - mean_ ) ** 2)
		end

		return Math.sqrt(sum.to_f/@length)
	end

	# this method returns the root mean square error of the prediction
	def rms
		sum=0

		@error.each do |error|
			sum += (error) ** 2
		end

		return Math.sqrt(sum.to_f/@length)
	end

	# this method returns an array of the predictions in the form [u,m,r,p].
	def to_a
		print @ratinglist
		puts
	end
			

end





obj=MovieData.new("ml-100k", :u2)

#puts obj.similarity(1,126)
#puts obj.most_similar(1)


#puts obj.viewers(100)

#t=obj.run_test(2500)
#puts t.mean
#puts t.stddev
#puts t.rms
#t.to_a
#puts t.rms





