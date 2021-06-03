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
            urlParams[ 'namedGraph'] = $(this).attr('namedGraph');
        } else if (collection_type == 'die') {
            urlParams[ 'die'] = $('#recordId').text();
            urlParams[ 'namedGraph'] = $(this).attr('namedGraph');
        } else if (collection_type == 'symbol') {
            urlParams[ 'uri'] = $('#objectURI').text();
        }        
        
        renderNetworkGraph(id, path, collection_type, urlParams);
    });
});

//initiate a call to the getDieLinks JSON API and parse the resulting object into a d3plus Network
function renderNetworkGraph(id, path, collection_type, urlParams) {
    var api = (collection_type == 'symbol' ? 'getSymbolLinks' : 'getDieLinks'); 

    //alert(urlParams);
    $('#' + id).removeClass('hidden');
    $('#' + id).height(600);
    
    $.get(path + 'apis/' + api, $.param(urlParams, true),
    function (data) {
        var nodeArray = data[ 'nodes'];
        var edgeArray = data[ 'edges'];
        
        const network = new d3plus.Network().config({
            links: edgeArray,
            linkSize: function (edge) {
                return edge.weight;
            },
            nodes: nodeArray,
            groupBy: function (node) {
                return node.side;
            },
            label: function (node) {
                if (node.hasOwnProperty('image')) {
                    return node.label + ' <img src="' + node.image + '" style="width:16px"/>';
                } else {
                    return node.label;
                }
                
            },
            color: function (node) {
                if (node.side == 'obv' || node.side == 'altSymbol') {
                    return '#282f6b'
                } else if (node.side == 'rev') {
                    return '#b22200';
                } else if (node.side == 'both') {
                    return '#7e12cc';
                } else {
                    return '#a8a8a8';
                }
            }
        }).on("click", function (node) {
            window.location.href = node.uri;
        }).select('#' + id).render();
    });
}