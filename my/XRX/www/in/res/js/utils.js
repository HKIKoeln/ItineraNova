
function highlightTab(tab)
{
    var tabs = document.getElementsByClassName('highlight-tab');
    for (n = 0; n < tabs.length; n++)
    {
        document.getElementsByClassName('highlight-tab')[n].style.backgroundColor='white';
    }
    document.getElementsByClassName('highlight-tab')[tab].style.backgroundColor='rgb(255,255,204)';
}

function highlightAddedTab()
{
    var tabs = document.getElementsByClassName('highlight-tab');
    for (n = 0; n < tabs.length; n++)
    {
        document.getElementsByClassName('highlight-tab')[n].style.backgroundColor='white';
    }
    document.getElementsByClassName('highlight-tab')[0].style.backgroundColor='rgb(255,255,204)';
}
