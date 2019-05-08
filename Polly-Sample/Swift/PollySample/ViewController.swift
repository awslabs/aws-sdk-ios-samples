/*
* Copyright 2010-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import UIKit
import AVFoundation
import AWSPolly

class ViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var voicePicker: UIPickerView!
	@IBOutlet weak var trailingSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var stackView: UIStackView!

	let sampleTexts: [AWSPollyVoiceId: String] = [
		//Danish
		AWSPollyVoiceId.mads: "Hej! Mit navn er Mads. Jeg kan oplæse enhver tekst, som du skriver her.",
		AWSPollyVoiceId.naja: "Hej! Mit navn er Naja. Jeg kan oplæse enhver tekst, som du skriver her.",

        //Dutch
        AWSPollyVoiceId.lotte: "Hoi! mijn naam is Lotte. Ik lees elke tekst voor die je hier invoert.",
        AWSPollyVoiceId.ruben: "Hoi! mijn naam is Ruben. Ik lees elke tekst voor die je hier invoert.",

        //English (Australian)
        AWSPollyVoiceId.nicole: "Hi there, my name is Nicole. I will read any text you type here.",
        AWSPollyVoiceId.russell: "Hi there, my name is Russel. I will read any text you type here.",
        
        //English (British)
        AWSPollyVoiceId.amy: "Hi! My name is Amy. I will read any text you type here.",
        AWSPollyVoiceId.brian: "Hi! My name is Brian. I will read any text you type here.",
        AWSPollyVoiceId.emma: "Hi! My name is Emma. I will read any text you type here.",

        //English (Indian)
        AWSPollyVoiceId.raveena: "Hi! My name is Raveena. I can read any text you type here.",
        AWSPollyVoiceId.aditi: "Hi! My name is Aditi. I can read any text you type here.",
        
        //English (US)
        AWSPollyVoiceId.ivy: "Hi! My name is Ivy. I will read any text you type here.",
        AWSPollyVoiceId.joanna: "Hi! My name is Joanna. I will read any text you type here.",
        AWSPollyVoiceId.joey: "Hi! My name is Joey. I will read any text you type here.",
        AWSPollyVoiceId.justin: "Hi! My name is Justin. I will read any text you type here.",
        AWSPollyVoiceId.kendra: "Hi! My name is Kendra. I will read any text you type here.",
        AWSPollyVoiceId.kimberly: "Hi! My name is Kimberly. I will read any text you type here.",
        AWSPollyVoiceId.matthew: "Hi! My name is Matthew. I will read any text you type here.",
        AWSPollyVoiceId.salli: "Hi! My name is Salli. I will read any text you type here.",

        //English (Welsh)
        AWSPollyVoiceId.geraint: "Hi! I'm Geraint. I can read any text you type here",

        //French
        AWSPollyVoiceId.celine: "Salut, je m'appelle Céline. Je vais lire le texte que vous écrirez ici.",
        AWSPollyVoiceId.mathieu: "Salut, je m'appelle Mathieu. Je vais lire le texte que vous écrirez ici.",
        AWSPollyVoiceId.lea: "Salut, je m'appelle Lea. Je vais lire le texte que vous écrirez ici.",
        
        //French (Canadian)
        AWSPollyVoiceId.chantal: "Salut, je m'appelle Chantal. Je vais lire le texte que vous écrirez ici.",

        //German
        AWSPollyVoiceId.hans: "Hallo, mein Name ist Hans. Ich werde jeden Text vorlesen, den Sie eingeben.",
		AWSPollyVoiceId.marlene: "Hallo, mein Name ist Marlene. Ich werde jeden Text vorlesen, den Sie eingeben.",
        AWSPollyVoiceId.vicki: "Hallo, mein Name ist Vicki. Ich werde jeden Text vorlesen, den Sie eingeben.",

	//Icelandic
        AWSPollyVoiceId.dora: "Ég heiti Dóra. Ég les upphátt allan texta sem þú skrifar hér.",
        AWSPollyVoiceId.karl: "Ég heiti Karl. Ég les upphátt allan texta sem þú skrifar hér.",

        //Italian
        AWSPollyVoiceId.carla: "Ciao, mi chiamo Carla. Leggerò qualsiasi testo che digiterai qui.",
        AWSPollyVoiceId.giorgio: "Ciao, mi chiamo Giorgio. Leggerò qualsiasi testo che digiterai qui.",

        //Japanese
        AWSPollyVoiceId.mizuki: "はじめまして。ミズキです。読みたいテキストを入力してください。",
        AWSPollyVoiceId.takumi: "はじめまして。ミズキです。読みたいテキストを入力してください。",
		
		//Korean
        AWSPollyVoiceId.seoyeon: "안녕하세요? 외국어를 구사하십니까? 이 세상에는 수많은 언어들이 있답니다。",
        
        //Norwegian
        AWSPollyVoiceId.liv: "Hei! Jeg heter Liv. Skriv inn noe her, så leser jeg det opp.",

        //Polish
        AWSPollyVoiceId.ewa: "Cześć, mam na imię Ewa. Przeczytam każdy tekst, który tutaj wpiszesz.",
        AWSPollyVoiceId.jacek: "Cześć, mam na imię Jacek. Przeczytam każdy tekst, który tutaj wpiszesz.",
        AWSPollyVoiceId.jan: "Cześć, mam na imię Jan. Przeczytam każdy tekst, który tutaj wpiszesz.",
        AWSPollyVoiceId.maja: "Cześć, mam na imię Maja. Przeczytam każdy tekst, który tutaj wpiszesz.",

        //Portugese (Brazilian)
        AWSPollyVoiceId.ricardo: "Olá, meu nome é Ricardo. Eu posso ler qualquer texto que você digitar aqui.",
        AWSPollyVoiceId.vitoria: "Olá, meu nome é Vitória. Eu posso ler qualquer texto que você digitar aqui.",

        //Portugese (Europian)
        AWSPollyVoiceId.cristiano: "Olá! O meu nome é Cristiano. Vou ler o texto que escrever aqui.",
        AWSPollyVoiceId.ines: "Olá! O meu nome é Inês. Vou ler o texto que escrever aqui.",

        //Romanian
        AWSPollyVoiceId.carmen: "Bună, numele meu este Carmen. Pot citi orice text introdus aici.",

        //Russian
        AWSPollyVoiceId.maxim: "Привет! Меня зовут Максим. Я прочитаю любой текст который вы введете здесь.",
        AWSPollyVoiceId.tatyana: "Привет! Меня зовут Татьяна. Я прочитаю любой текст который вы введете здесь.",

        //Spanish (Castilian)
        AWSPollyVoiceId.conchita: "Hola! Mi nombre es Conchita. Puedo leer cualquier texto que introduzcas aquí.",
		AWSPollyVoiceId.enrique: "Hola! Mi nombre es Enrique. Puedo leer cualquier texto que introduzcas aquí.",

        //Spanish (Latin American)
		AWSPollyVoiceId.miguel: "Hola! Mi nombre es Miguel. Puedo leer cualquier texto que introduzcas aquí.",
		AWSPollyVoiceId.penelope: "Hola! Mi nombre es Penelope. Puedo leer cualquier texto que introduzcas aquí.",
        
        //Swedish
		AWSPollyVoiceId.astrid: "Hejsan! Jag heter Astrid och läser upp det som skrivs här.",

        //Turkish
		AWSPollyVoiceId.filiz: "Merhaba, benim adım Filiz. Buraya girdiğiniz her metni okuyabilirim.",
        
        //Welsh
        AWSPollyVoiceId.gwyneth: "Helo 'na! Gwyneth ydw i. Teipiwch unrhywbeth yma a fe wna i ei ddarllen."
	]

	var originalConstraint: CGFloat!
	@objc var audioPlayer = AVPlayer()
	var selectedVoice: AWSPollyVoiceId!

	@objc var pickerNames: [String] = [String]()
	var pickerValues: [AWSPollyVoiceId] = [AWSPollyVoiceId]()

	override func viewDidLoad() {
		super.viewDidLoad()

		voicePicker.dataSource = self
		voicePicker.delegate = self

		// Get all the voices (no parameters specified in input) from Polly
		// This creates an async task.
		let task = AWSPolly.default().describeVoices(AWSPollyDescribeVoicesInput())

		// When the request is done, asynchronously do the following block
		// (we ignore all the errors, but in a real-world scenario they need
		// to be handled)
		task.continueOnSuccessWith { (awsTask: AWSTask<AWSPollyDescribeVoicesOutput>) -> Any? in
			// awsTask.result is an instance of AWSPollyDescribeVoicesOutput in
			// case of the "describeVoices" method
			let data = (awsTask.result! as AWSPollyDescribeVoicesOutput).voices

			// Sort the voices by the language
			let sortedVoices = data!.sorted(by: { $0.languageName! < $1.languageName! })

			// We select the American Joanna voice by default
			self.selectedVoice = AWSPollyVoiceId.joanna

			var selectedVoiceIndex: Int = 0

			// Then, we populate the voice picker with our voices.
			// pickerNames holds the human-readable labels, while
			// pickerValues contains the raw voice identifiers
			for (index, item) in sortedVoices.enumerated() {
				self.pickerNames.append(item.name! + " (" + item.languageName! + ")")
				self.pickerValues.append(item.identifier)

				if item.identifier == self.selectedVoice {
					selectedVoiceIndex = index
				}
			}

			// Need to update the UI, which is done in the main thread
			DispatchQueue.main.async {
				self.textField.placeholder = self.sampleTexts[self.selectedVoice]

				self.voicePicker.reloadAllComponents()
				self.voicePicker.selectRow(selectedVoiceIndex, inComponent: 0, animated: false)
			}

			return nil
		}.waitUntilFinished()

		// Handle keyboard changing frame
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

		// Handle taping anywhere in the view outside text field and picker to dismiss the keyboard
		let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
		view.addGestureRecognizer(tap)

		// Save the original constraint to restore it after keyboard is closed
		originalConstraint = trailingSpaceConstraint.constant
	}

	deinit {
		// Remove the keyboard frame change observer
		NotificationCenter.default.removeObserver(self)
	}

	// Number of components in the voice picker, in our case there is only 1
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	// When a row is selected, switch selectedVoice to the value of the picker
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedVoice = pickerValues[row]

		textField.placeholder = sampleTexts[selectedVoice!]
	}

	// Return the title for the given picker row. We get them from our pickerNames
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerNames[row]
	}

	// Return the number of voice names in the picker
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerNames.count
	}

	// Handle keyboard frame changes
	@objc private func keyboardWillChange(notification: NSNotification) {
		let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
		let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt

		let currentFrameY = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.origin.y
		let targetFrameY = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.origin.y

		var deltaY: CGFloat

		if currentFrameY > targetFrameY {
			// Keyboard is being shown

			deltaY = min(targetFrameY - stackView.frame.maxY, 0.0)
		} else {
			// Keyboard is starting to hide
			deltaY = min(originalConstraint - self.trailingSpaceConstraint.constant, targetFrameY - currentFrameY)
		}

		// Update constraints before changing layout
		self.view.updateConstraintsIfNeeded()

		UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
			self.trailingSpaceConstraint.constant += deltaY

			self.view.layoutIfNeeded()
		}, completion: nil)
	}

	// Dismiss keyboard (passed to event handler)
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func buttonClicked(_ sender: AnyObject) {
		// First, Polly requires an input, which we need to prepare.
		// Again, we ignore the errors, however this should be handled in
		// real applications. Here we are using the URL Builder Request,
		// since in order to make the synthesis quicker we will pass the
		// presigned URL to the system audio player.
		let input = AWSPollySynthesizeSpeechURLBuilderRequest()

		// Text to synthesize, taken from the text field
		if textField.text != "" {
			input.text = textField.text!
		} else {
			input.text = textField.placeholder!
		}

		// We expect the output in MP3 format
		input.outputFormat = AWSPollyOutputFormat.mp3

		// Use the voice we selected earlier using picker to synthesize
		input.voiceId = selectedVoice

		// Create an task to synthesize speech using the given synthesis input
		let builder = AWSPollySynthesizeSpeechURLBuilder.default().getPreSignedURL(input)

		// Request the URL for synthesis result
		builder.continueOnSuccessWith { (awsTask: AWSTask<NSURL>) -> Any? in
			// The result of getPresignedURL task is NSURL.
			// Again, we ignore the errors in the example.
			let url = awsTask.result!

			// Try playing the data using the system AVAudioPlayer
			self.audioPlayer.replaceCurrentItem(with: AVPlayerItem(url: url as URL))
			self.audioPlayer.play()

			return nil
		}
	}
}

