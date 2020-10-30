/*******
FORCED NETWORK GRAPH FUNCTIONS FOR D3PLUS
Modified: October 2020
Function: These are the functions for generating a forced network graph for die and type pages when a die study is actived.
 *******/

$(document).ready(function () {
    var collection_type = $('#collection_type').text();
    var path = '../';
    
    /**** RENDER CHART ****/
    $('.network-graph').each(function () {
        var id = $(this).attr('id');
        
        var urlParams = {
        };
        
        if (collection_type == 'cointype') {
            urlParams[ 'type'] = $('#recordId').text();
        } else if (collection_type == 'die') {
            urlParams[ 'die'] = $('#recordId').text();
        }
        urlParams[ 'namedGraph'] = $(this).attr('namedGraph');
        
        renderNetworkGraph(id, path, urlParams);
    });
    
    //render the chart on button click ajax trigger on ID page--do not reload page with request params
});


function renderNetworkGraph(id, path, urlParams) {
    //alert(urlParams);
    $('#' + id).removeClass('hidden');
    $('#' + id).height(600);
    
    $.get(path + 'apis/getDieLinks', $.param(urlParams, true),
    function (data) {
        var nodeArray = data['nodes'];
        var edgeArray = data['edges'];
        
        const network = new d3plus.Network().config({
            links: edgeArray,
            linkSize: function (d) {
                return d.weight;
            },
            nodes: nodeArray
        }).select('#' + id).render();
    });
}