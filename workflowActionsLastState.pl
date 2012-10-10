# Copyright (c) 2012 Nikhil Vaze
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Demonstrates how to find the previous state of a running workflow.
# http://ask.electric-cloud.com/questions/815/followup-question-about-getting-previous-state-for-an-electriccommander-workflow

use strict;
use warnings;
use ElectricCommander;

use XML::XPath;

# Turn off buffering
$| = 1;

# Create an ElectricCommander object to communicate with a server.
my $ec = new ElectricCommander( { debug => 1 } );

my @filterList;

# For a given workflowId...
my $workflowId = '1030';

# Create the filterList
push(
    @filterList,
    {
        propertyName => 'workflowId',
        operator     => 'equals',
        'operand1'   => $workflowId
    },

);

# Perform the findObjects query, sort by index.
# During parsing we will look for the last transitionId.
my $result = $ec->findObjects(
    'workflowAction',
    {
        filter => \@filterList,
        sort   => [
            {
                propertyName => 'index',
                order        => 'ascending'
            }
        ]
    }
);

# Get the last transitionId
my $transitionId = $result->findnodes(
    '/responses/response/object[last()]/workflowAction/transitionId')
  ->string_value();

# Give the last transitionId to the getObjects API
$result = $ec->getObjects( { objectId => "transition-$transitionId" } );

# Output the state name which contains the name of the previous state
print 'Previous state is: ' . $result->findvalue('//stateName')->value() . "\n";
