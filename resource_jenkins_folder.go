package main

import (
	"errors"
	"log"
	"strings"

	jenkins "github.com/charlieegan3/gojenkins"
	"github.com/hashicorp/terraform/helper/schema"
)

type folderPath struct {
	Name    string
	Parents []string
}

func buildFolderFromPath(path string) (folderPath, error) {
	words := strings.Split(path, "/")
	lastIndex := len(words) - 1

	if len(words) == 0 {
		return folderPath{}, errors.New("Empty path")
	} else if len(words) == 1 {
		return folderPath{Name: words[lastIndex]}, nil
	}
	return folderPath{Name: words[lastIndex], Parents: words[0:lastIndex]}, nil
}

func resourceJenkinsFolder() *schema.Resource {
	return &schema.Resource{
		Create: resourceJenkinsFolderCreate,
		Delete: resourceJenkinsFolderDelete,
		Exists: resourceJenkinsFolderExists,
		Read:   resourceJenkinsFolderRead,
		Update: resourceJenkinsFolderUpdate,
		Schema: map[string]*schema.Schema{
			// this is the folder's ID (primary key)
			"name": &schema.Schema{
				Type:        schema.TypeString,
				Description: "The unique name of the JenkinsCI folder.",
				Required:    true,
			},
		},
	}
}

func resourceJenkinsFolderExists(d *schema.ResourceData, meta interface{}) (b bool, e error) {
	client := meta.(*jenkins.Jenkins)
	name := d.Get("name").(string)

	log.Printf("[DEBUG] jenkins::exists - checking if folder %q exists", name)

	_, err := client.GetFolder(name)
	if err != nil {
		log.Printf("[DEBUG] jenkins::exists - folder %q does not exist: %v", name, err)
		// TODO: check error when resource does not exist
		// remove from state
		d.SetId("")
		return false, nil
	}

	log.Printf("[DEBUG] jenkins::exists - folder %q exists", name)
	return true, nil
}

func resourceJenkinsFolderCreate(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*jenkins.Jenkins)
	name := d.Get("name").(string)

	folderPath, err := buildFolderFromPath(d.Get("name").(string))
	if err != nil {
		log.Printf("[ERROR] jenkins::create - error parsing path")
		return err
	}

	log.Printf("[DEBUG] jenkins::create - folder: %v", folderPath)
	folder, err := client.CreateFolder(folderPath.Name, folderPath.Parents...)
	if err != nil {
		log.Printf("[ERROR] jenkins::create - error creating folder for %q: %v", name, err)
		return err
	}

	log.Printf("[DEBUG] jenkins::create - folder %q created", name)

	d.SetId(folder.GetName())
	d.Set("hash", name)
	return err
}

func resourceJenkinsFolderRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*jenkins.Jenkins)
	name := d.Get("name").(string)

	log.Printf("[DEBUG] jenkins::read - looking for folder %q", name)

	folder, err := client.GetFolder(name)
	if err != nil {
		log.Printf("[DEBUG] jenkins::read - folder %q does not exist: %v", name, err)
		return err
	}

	log.Printf("[DEBUG] jenkins::read - folder %q found", name)

	d.SetId(folder.GetName())

	return nil
}

func resourceJenkinsFolderDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*jenkins.Jenkins)
	name := d.Id()

	log.Printf("[DEBUG] jenkins::delete - removing %q", name)

	ok, err := client.DeleteFolder(name)

	log.Printf("[DEBUG] jenkins::delete - %q removed: %t", name, ok)
	return err
}

func resourceJenkinsFolderUpdate(d *schema.ResourceData, meta interface{}) error {
	log.Printf("[DEBUG] jenkins::update - no-op, not yet implemented")

	return nil
}
