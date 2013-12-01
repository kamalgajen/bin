 #!/d/RailsInstaller/Ruby1.9.2/bin/ruby

require 'date'
require 'optparse'
require './MConfig'

# this script generate big datasets for performance and scalability
# evaluations.  Should eventually be customizable, based on some input 
# parameters
# usage: ruby generate_big_data.rb -o dataset.csv -c datagen.config
# @kgajendr

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: generate_big_data.rb [options]"
  opts.on('-o [ARG]', '--configFileName [ARG]', "Specify config file name") do |v|
    options[:outputFileName] = v
  end
  opts.on('-c [ARG]', '--outputFileName [ARG]', "Specify output file name") do |v|
    options[:configFileName] = v
  end
  options[:header] = false;
  opts.on('-1', '--header', "Specify output file name") do 
    options[:header] = true
  end
  options[:autoincrement] = false;
  opts.on('-i', '--autoincrement', 'Automatically include a auto-increment key as the first column') do 
    options[:autoincrement] = true;
  end
  opts.on('-h', '--help', 'Display this help') do 
    puts opts
    exit
  end
end.parse!


# this setting can be changed via the input config file
$printUniqueRowKey = options[:autoincrement]
$counter = 0
  
# output file
$outputFile = File.new(options[:outputFileName], "w")

######################################################################
# generate a random integer between min & the maxInt
######################################################################
def getRandomInteger(minInt, maxInt)
  intValue = minInt + rand(maxInt-minInt+1)
  return intValue
end

######################################################################
# generate a random float between the min and maxFloat
######################################################################
def getRandomFloat(minFloat, maxFloat)
  gap = maxFloat - minFloat
  rfloat = ((rand*gap)+minFloat)*100
  rfloat = rfloat.round
  rfloat = rfloat / 100.0
  return rfloat
end

######################################################################
# generate a date between the min and maxDate
######################################################################
def getRandomDate(minDate, maxDate)
  gap = maxDate-minDate
  gap.to_i

  return minDate + rand(gap.to_i + 1)

end

######################################################################
# read the csv file, and create an config object for each valid row.  To 
# keep track of all the rows and their orders, add them to an array
######################################################################
def readCSV(configFile)
  file = File.new(configFile, 'r')

  columnObjectArray = Array.new

  file.each_line("\n") do |row|
    next if row =~ /^#/
    columns = row.chomp.split(",", -1)
    next if columns.size < 5 && columns.size != 2

    conf = MConfig.new(columns[0], columns[1], columns[2], columns[3], columns[4]);
    columnObjectArray.push conf;
  end

  file.close

  return columnObjectArray
end

######################################################################
# print header
######################################################################
def printHeader(columnObjectArray)
  
  $outputFile.print "rowid," if $printUniqueRowKey
  
  $outputFile.print columnObjectArray.first.getColumnName.downcase
  
  for i in 1..columnObjectArray.length-1 
    $outputFile.print ",", columnObjectArray[i].getColumnName.downcase
  end

  $outputFile.print "\n"
end


######################################################################
# get the number of keys
######################################################################
def getKeyCount(columnObjectArray)
  keyCount = 0;  
  for i in 0..columnObjectArray.length-1 
    if columnObjectArray[i].getColumnType.upcase == "KEY"
      keyCount += 1
    end
  end

  return keyCount
end


######################################################################
# print data
# since we are generating a lot of data, with a vairable number of keys,
# there is no clean way to do this.  Recursion is out of question, as 
# it will lead to a stack overflow with big data sets.
# so this is the best I could think of - any other creative ways?
######################################################################
def printData(columnObjectArray)

  keyCount = getKeyCount(columnObjectArray)
  
  if (keyCount > 4)
    print "Only 4 keys are supported currently. Script has to be modified before more keys can be supported"
    return
  end
  
  
  
  # first key
  for i in columnObjectArray[0].getMinValue..columnObjectArray[0].getMaxValue
    if (keyCount == 1)
      printValues("#{i}", columnObjectArray, 1, columnObjectArray.length-1)
      next
    end
    
    # second key
    for j in columnObjectArray[1].getMinValue..columnObjectArray[1].getMaxValue
      if (keyCount == 2)
        printValues("#{i},#{j}", columnObjectArray, 2, columnObjectArray.length-1)
        next        
      end
          
      # third key  
      for k in columnObjectArray[2].getMinValue..columnObjectArray[2].getMaxValue
        if (keyCount == 3)
          printValues("#{i},#{j},#{k}", columnObjectArray, 3, columnObjectArray.length-1)
          next        
        end

        # forth key  
        for l in columnObjectArray[3].getMinValue..columnObjectArray[3].getMaxValue
          if (keyCount == 4)
            printValues("#{i},#{j},#{k},#{l}", columnObjectArray, 4, columnObjectArray.length-1)
            next        
          end

        end # forth key
      end # third key
    end # seocnd key
  end # first key
  
end

######################################################################
# generate and print values (random based on configuration)
######################################################################
def printValues(keyString, columnObjectArray, startIndex, endIndex)
  
  if $printUniqueRowKey
    $counter += 1
    $outputFile.print $counter
    $outputFile.print ","
  end
  
  $outputFile.print keyString
  
  if startIndex > endIndex
    return
  end
    
  for m in startIndex..endIndex
    $outputFile.print ","
    if columnObjectArray[m].getColumnDataType.upcase == "INTEGER"
      $outputFile.print getRandomInteger(columnObjectArray[m].getMinValue, columnObjectArray[m].getMaxValue)
    elsif columnObjectArray[m].getColumnDataType.upcase == "FLOAT"
      $outputFile.print getRandomFloat(columnObjectArray[m].getMinValue, columnObjectArray[m].getMaxValue)
    elsif columnObjectArray[m].getColumnDataType.upcase == "TEXT"
      $outputFile.print "sample text"
    elsif columnObjectArray[m].getColumnDataType.upcase == "DATE"
      $outputFile.print getRandomDate(columnObjectArray[m].getMinDate, columnObjectArray[m].getMaxDate)
    end
  end

  $outputFile.print "\n"
  
end


######################################################################
# main
######################################################################

columnObjectArray = readCSV(options[:configFileName])

printHeader(columnObjectArray) if options[:header]
printData(columnObjectArray)

#name = gets.chomp
#puts "Hello #{name}!"

$outputFile.close

exit
