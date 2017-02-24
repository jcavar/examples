//
//  ViewController.swift
//  TestAsyncFetchCoreData
//
//  Created by Josip Cavar on 23/02/2017.
//  Copyright © 2017 novastonemedia. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        _ = ExampleEntity(context: context)
        try? context.save()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExampleEntity")
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { results in
            print(results.finalResult ?? [])
        }

        context.perform {
            // This crashes
            _ = try? context.execute(asyncRequest)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

