//
// Copyright 2014-2018 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License").
// You may not use this file except in compliance with the
// License. A copy of the License is located at
//
//     http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, express or implied. See the License
// for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import AWSCognitoIdentityProvider

class DevicesDetailTableViewController: UITableViewController {
    var response: AWSCognitoIdentityUserListDevicesResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        self.refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.response!.devices![section].deviceKey!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let devices = self.response?.devices {
            return devices.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let response = self.response {
            return response.devices![section].deviceAttributes!.count + 3
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let cell = tableView.dequeueReusableCell(withIdentifier: "attribute", for: indexPath)
        let device = self.response!.devices![indexPath.section]
        if indexPath.row < 3 {
            switch indexPath.row {
            case 0:
                cell.textLabel!.text! = "Create Date"
                cell.detailTextLabel!.text! = formatter.string(from: device.deviceCreateDate!)
                break
            case 1:
                cell.textLabel!.text! = "Last Authenticated"
                cell.detailTextLabel!.text! = formatter.string(from: device.deviceLastAuthenticatedDate!)
                break
            case 2:
                cell.textLabel!.text! = "Last Modified"
                cell.detailTextLabel!.text! = formatter.string(from: device.deviceLastModifiedDate!)
                break
            default:
                break
            }
        }
        else {
            let attribute = device.deviceAttributes![indexPath.row - 3]
            cell.textLabel!.text! = attribute.name!
            cell.detailTextLabel!.text! = attribute.value!
        }
        return cell
    }
    
    func refresh() {
        self.user!.listDevices(10, paginationToken: nil).continueWith { (task) -> Any? in
            DispatchQueue.main.async(execute: {() -> Void in
                self.response = task.result
                self.title = "Devices"
                self.tableView.reloadData()
            })
            return nil
        }
    }
}
