from lxml import html
import requests
import csv
import json
import os.path
import sys

commentcsv = 'comments.csv'

prof_headers = ['ProfessorId', 'Fname', 'Lname', 'School', 'Department', 'OverallQuality',
            'WouldTakeAgain', 'LevelOfDifficulty', 'Tags']


if not os.path.isfile(profcsv):
    with open(profcsv, 'w') as f:
        writer = csv.writer(f)
        writer.writerow(prof_headers)
        f.close()


base_prof_url = 'http://www.ratemyprofessors.com/ShowRatings.jsp?tid={0}'

# implement method to iterate over all professor IDs
# Make sure that it updating, rather than overwriting, the CSVs
# Create method of handling an invalid page. Simply skip?
id = 23330069
while True:
    print('Current TID: ', id)
    try:
        page = requests.get(base_prof_url.format(id))
        tree = html.fromstring(page.content)

        # Scrape all data for the professor
        fname = tree.xpath('//h1[@class="profname"]/span[@class="pfname"]/text()')[0].strip()
        lname = tree.xpath('//span[@class="plname"]/text()')[0].strip()
        school = tree.xpath('//a[@class="school"]/text()')[0].strip()
        department = tree.xpath('//div[@class="result-title"]/text()')[0].strip()
        quality_scores = tree.xpath('//div[@class="grade"]/text()')
        hotness = tree.xpath('//div[@class="breakdown-section"]/div[@class="grade"]/figure/img/@src')
        overall_quality = quality_scores[0].strip()
        would_take_again = quality_scores[1].strip()
        level_difficulty = quality_scores[2].strip()
        tags = tree.xpath('//span[@class="tag-box-choosetags"]/text()')

        with open(profcsv, 'a') as f:
            prof_row = [id, fname, lname, school, department, overall_quality, hotness,
                        would_take_again, level_difficulty, ';'.join(tags)]
            writer = csv.writer(f)
            writer.writerow(prof_row)
            f.close()

        id = id + 1
    except KeyboardInterrupt:
        quit()
    except:
        print("Error = {0}", sys.exc_info()[0])
        print('Not a valid page')
        id = id + 1
