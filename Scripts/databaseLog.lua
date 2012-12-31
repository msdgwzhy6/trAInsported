----------------------------------------
-- Attempt to connect to MySQL Database to store match results.

if CL_MYSQL_NAME then
	ok, msg = pcall(require, "luasql.mysql")

	if not ok then
		print("Could not load mysql. If you want to use MySQL logging, make sure the lua extension luasql is installed! Otherwise, ignore this warning.")
	else
		print("MYSQL driver loaded.")
		MYSQL = true
		luasql = msg
	end
end


log = {}

function log.newWinner(ID)
	print("attempting to log winner")
	if MYSQL then
		print("mysql found")
		if aiList[ID].name then
			-- open MYSQL environment:
			env = luasql.mysql()
			
			if env then
				print("loaded mysql driver!")
				conn = env:connect(MYSQL_DATABASE, CL_MYSQL_NAME, CL_MYSQL_PASS, CL_MYQSL_HOST, CL_MYSQL_PORT)
				if conn then
					print("connection successful!")
					result = nil
					cursor,err = conn:execute("SELECT name FROM ais WHERE name LIKE '" .. aiList[ID].name .. "';")
					if not cursor then
						print(err)
					else
						result = cursor:fetch()
						cursor:close()
					end
					if result then
						print("Found " .. aiList[ID].name .. " in Database!")						
					else
						print("Didn't find " .. aiList[ID].name .. " in Database. Attempting to add.")
						cursor, err = conn:execute("INSERT INTO ais VALUE('" .. aiList[ID].name .. "','Unknown',0,0,0,'"  .. aiList[ID].name .. ".lua');")
						if not cursor then
							print(err)
						elseif type(cursor) == "table" then
							print("result:")
							printTable(cursor)
							cursor:close()
						else
							print("result",cursor)
						end
					end
					
					cursor,err = conn:execute("UPDATE ais SET wins=wins+1 WHERE name LIKE '" .. aiList[ID].name .. "';")
--					UPDATE persondata SET age=age+1;
					if not cursor then
						print(err)
					elseif type(cursor) == "table" then
						print("result:")
						printTable(cursor)
						cursor:close()
					else
						print("result",cursor)
					end
					conn:close()
				else
					print("Error connecting to MySQL. Does the database exist?")
				end
				env:close()
			else
				print("Error opening MySQL environment.")
			end
		end
	end
end


function log.newMatch(ID)
	print("attempting to log match")
	if MYSQL then
		print("mysql found")
		if aiList[ID].name then
			-- open MYSQL environment:
			env = luasql.mysql()
			
			if env then
				print("loaded mysql driver!")
				conn = env:connect(MYSQL_DATABASE, CL_MYSQL_NAME, CL_MYSQL_PASS, CL_MYQSL_HOST, CL_MYSQL_PORT)
				if conn then
					print("connection successful!")
					result = nil
					cursor,err = conn:execute("SELECT name FROM ais WHERE name LIKE '" .. aiList[ID].name .. "';")
					if not cursor then
						print(err)
					else
						result = cursor:fetch()
						cursor:close()
					end
					if result then
						print("Found " .. aiList[ID].name .. " in Database!")						
					else
						print("Didn't find " .. aiList[ID].name .. " in Database. Attempting to add.")
						cursor, err = conn:execute("INSERT INTO ais VALUE('" .. aiList[ID].name .. "','Unknown',0,0,0,'"  .. aiList[ID].name .. ".lua');")
						if not cursor then
							print(err)
						elseif type(cursor) == "table" then
							print("result:")
							printTable(cursor)
							cursor:close()
						else
							print("result",cursor)
						end
					end
					
					cursor,err = conn:execute("UPDATE ais SET matches=matches+1 WHERE name LIKE '" .. aiList[ID].name .. "';")
--					UPDATE persondata SET age=age+1;
					if not cursor then
						print(err)
					elseif type(cursor) == "table" then
						print("result:")
						printTable(cursor)
						cursor:close()
					else
						print("result",cursor)
					end
					conn:close()
				else
					print("Error connecting to MySQL. Does the database exist?")
				end
				env:close()
			else
				print("Error opening MySQL environment.")
			end
		end
	end
end

function log.findTable()
	if MYSQL then
	
		env = luasql.mysql()
		
		if env then
			conn = env:connect(MYSQL_DATABASE, CL_MYSQL_NAME, CL_MYSQL_PASS, CL_MYQSL_HOST, CL_MYSQL_PORT)
			if conn then
				cursor = conn:execute("SHOW TABLES LIKE 'ais';")		-- see if the "ais" table exists. if not, attempt to create it:
				
				result = cursor:fetch()
				cursor:close()
				if result then
					found = true
					print("Found table 'ais'. Success!")
				else
					cursor = conn:execute("CREATE TABLE ais (name VARCHAR(30), owner VARCHAR(30), matches INT, wins INT, cash INT, scriptName VARCHAR(40));")		-- see if the "ais" table exists. if not, attempt to create it:
					if cursor then
						found = true
						print("Created table 'ais' in " .. MYSQL_DATABASE .. ".")
					end
					cursor:close()
				end
				conn:close()
			else
				print("Error connecting to MySQL. Does the database exist?")
			end
		end
		
		if not found then
			MYSQL = false
			print("Could not find nor create table 'ais' in '" .. MYSQL_DATABASE .. "'... disabling MySQL logging.")
		end
		
	end
end

return log
