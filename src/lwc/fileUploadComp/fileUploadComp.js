import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploader.uploadFile'
export default class fileUploadComp extends LightningElement {
    @api recordId;
    @api fileURL;
    fileData
    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'filetype': file.type,
                'base64': base64
            }
            this.handleClick();
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
    }

    handleClick(){
        const {base64, filename,filetype} = this.fileData
        uploadFile({ base64, filename,filetype }).then(result=>{
            this.fileData = null;
            this.fileURL= result;
            let title = `${this.fileURL}`
            // this.handleCopy();
            // this.toast(title)
        })
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title,
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }

    handleCopy() {
        let copyMe = this.template.querySelector('.copy-me');
        copyMe.select();
        copyMe.setSelectionRange(0,9999999);
        document.execCommand('copy');
        this.fileURL = null;
    }
}
