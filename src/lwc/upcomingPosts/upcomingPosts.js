/**
 Author:         serhiivolynets
 Date:           27.08.2022
 Description:
 **/
import { LightningElement } from 'lwc';
export default class UpcomingPosts extends LightningElement {
    readFile(event) {
        textarea.textContent = event.target.result;
        console.log(event.target.result);
    }


    drag(event){
        event.dataTransfer.setData("divId", event.target.id);
    }
    allowDrop(event){
        event.preventDefault();
    }
    drop(event){
        event.preventDefault();
        console.log('myDrop');
        if(event.dataTransfer.items)
        {
            const data = event.dataTransfer.items;
            for (let i = 0; i < data.length; i++) {
                const item = data[i];
                // If dropped items aren't files, reject them
                console.log(`item.kind= ${item.kind}`);
                if (item.kind === 'file') {
                    const file = item.getAsFile();
                    var reader = new FileReader();
                    reader.addEventListener('load', this.readFile);
                    reader.readAsText(file);

                    console.log(`… file[${i}].name = ${file.name}`);
                }
            }
        }
        else
        {
            event.dataTransfer.files.forEach((file, i) => {
            console.log(`… file[${i}].name = ${file.name}`);
        });
        }
        var divId = event.dataTransfer.getData("divId");
        var draggedElement = this.template.querySelector('#' +divId);
        draggedElement.classList.add('completed');
        event.target.appendChild(draggedElement);
    }
}
