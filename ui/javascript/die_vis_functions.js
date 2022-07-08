/*******
DIE COUNT VISUALIZATION FUNCTIONS
Modified: July 2022
Function: Query Nomisma dieCounts API and display d3plus chart and other estimated die count statistics
 *******/

$(document).ready(function () {
    
    var urlParams = {
    };
    urlParams[ 'type'] = $('#objectURI').text();
    urlParams[ 'dieStudy'] = $('#dieStudy').text();
    
    renderDieCount(urlParams);
});

function renderDieCount (urlParams) {
    var title = "Die frequencies for " + $('#object_title').text();
    
    $.get('https://nomisma.org/apis/dieCounts/esty', $.param(urlParams, true),
    function (data) {
        var f = new Array();
        //combine the obverse and reverse frequencies into one array for d3plus visualization
        if (data.data.obverse.hasOwnProperty('frequencies')) {
            data.data.obverse.frequencies.forEach(function (item) {
                f.push(item);
            });
        }
        if (data.data.reverse.hasOwnProperty('frequencies')) {
            data.data.reverse.frequencies.forEach(function (item) {
                f.push(item);
            });
        }
        
        //display statistical data
        renderCounts(data, urlParams, 'obverse');
        renderCounts(data, urlParams, 'reverse');
        
        //render chart
        new d3plus.LinePlot().data(f).baseline(0).groupBy('side').x('frequency').y('dies').title(title).legend('true').legendPosition('bottom').lineMarkers('true').shapeConfig({
            Line: {
                strokeWidth: 2
            }
        }).xConfig({
            title: "Frequency"
        }).yConfig({
            title: "Number of dies"
        }).titleConfig({
            fontSize: 16,
            padding: 5
        }).tooltipConfig({
            title: function (d) {
                return "Dies: " + d[ "dies"];
            }
        }).select("#dieVis-chart").render();
    });
}

//create HTML display from
function renderCounts(data, urlParams, side) {
    var obj = data.data[side];
    var sideLabel = side[0].toUpperCase() + side.substring(1);
    
    var query = $('#die-frequencies-query').text().replace('%SIDE%', sideLabel).replace('%typeURI%', urlParams['type']).replace('%dieStudy%', urlParams['dieStudy']);
    var sparql_url = 'http://nomisma.org/query?query=' + encodeURIComponent(query) + "&output=csv";
    
    var html = '<div><h4>' + sideLabel + '<small style="margin-left:10px"><a href="' + sparql_url + '" title="Download CSV"><span class="glyphicon glyphicon-download"/>Download CSV</a></small></h4>';
    html += '<dl class="dl-horizontal">';
    if (obj.n == 0) {
        html += '<dt>Specimens (n)</dt><dd>0</dd>';
    } else {
        html += '<dt>Specimens (n)</dt><dd>' + obj.n + '</dd>';
        html += '<dt>Unique Dies (d)</dt><dd>' + obj.d + '</dd>';
        html += '<dt>Singletons (d<sub>1</sub>)</dt><dd>' + obj.d1 + '</dd>';
        html += '<dt>Coverage (c<sub>est</sub>)</dt><dd>' + obj.c_est + '</dd>';
        html += '<dt>Estimated Dies (d<sub>est</sub>)</dt><dd>' + obj.d_est + '</dd>';        
    }
    html += '</dl>';
    if (obj.n > 0) {
       html += '<p>With 95 percent confidence the original number of dies is between ' + obj.d_min + ' and ' + obj.d_max + '.</p>'; 
    }    
    html += '</div>';
    
    $('#dieCount-container').append(html);
}