sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'ns/adopter/test/integration/FirstJourney',
		'ns/adopter/test/integration/pages/AnimalsList',
		'ns/adopter/test/integration/pages/AnimalsObjectPage'
    ],
    function(JourneyRunner, opaJourney, AnimalsList, AnimalsObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('ns/adopter') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheAnimalsList: AnimalsList,
					onTheAnimalsObjectPage: AnimalsObjectPage
                }
            },
            opaJourney.run
        );
    }
);