/* Author: Trevor Frame
 * Date: 11/24/2020
 * Description: Widget for displaying the 'Most Popular'
 * section on the discover page. 
 * 
 *  Uses the flutter_rating_bar library found on pub dev
 * 
 * The MIT License (MIT)

    Copyright (c) 2019 Sarbagya Dhaubanjar

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
 * 
 */

import 'package:flutter/material.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MostPopular extends StatefulWidget {
  @override
  _MostPopularState createState() => _MostPopularState();
}

class _MostPopularState extends State<MostPopular> {
  int _selectedPopularityTimeFrame = 0;

  List<DropdownMenuItem<int>> _popularityTimeFrames = [];

  @override
  void initState() {
    _popularityTimeFrames.add(
      new DropdownMenuItem(
        child: new Text('Today'),
        value: 0,
      ),
    );
    _popularityTimeFrames.add(
      new DropdownMenuItem(
        child: new Text('Month'),
        value: 1,
      ),
    );
    _popularityTimeFrames.add(
      new DropdownMenuItem(
        child: new Text('Year'),
        value: 2,
      ),
    );
    _popularityTimeFrames.add(
      new DropdownMenuItem(
        child: new Text('All Time'),
        value: 3,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 18.0,
            horizontal: 18.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Most Popular',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 50,
                width: 100,
                child: DropdownButtonFormField(
                  items: _popularityTimeFrames,
                  value: _selectedPopularityTimeFrame,
                  onChanged: (value) {
                    setState(() {
                      _selectedPopularityTimeFrame = value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 0,
                    ),
                    labelText: 'Event type',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'title',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                    ),
                    child: RatingBarIndicator(
                      rating: 3.5,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemSize: 25,
                      itemPadding: EdgeInsets.symmetric(
                        horizontal: 1.0,
                      ),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Theme.of(context).buttonColor,
                      ),
                    ),
                  ),
                ],
              ),
              RatingBarIndicator(
                rating: 1.5,
                direction: Axis.horizontal,
                itemCount: 3,
                itemSize: 25,
                itemPadding: EdgeInsets.symmetric(
                  horizontal: 0.0,
                ),
                itemBuilder: (context, _) => Icon(
                  Icons.attach_money,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10.0,
          ),
          child: Container(
            height: 200,
            width: screenWidth * 0.9,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              child: Hero(
                tag: 'cozumel',
                child: Image.network(
                  'https://i.ytimg.com/vi/lhPs4IweziI/maxresdefault.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '3002 views',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '1578 likes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '581 done?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 10.0,
        ),
      ],
    );
  }
}
