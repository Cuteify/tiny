package packageSys

import (
	"encoding/json"
	"os"
	"path"
)

func GetPackage(packagePath string) *Info {
	// 列出目录下所有文件
	files, err := os.ReadDir(packagePath)
	if err!= nil {
		return nil
	}
	packFile, err := os.OpenFile(path.Join(packagePath, "package.json"), os.O_RDONLY, 0666)
	if err!= nil {
		return nil
	}
	defer packFile.Close()
	jsonDe := json.NewDecoder(packFile)
	packageInfo := &Info{}
	jsonDe.Decode(packageInfo)
	packageInfo.Path = packagePath
	for _, file := range files {
		if file.IsDir() {
			packageInfo.Children = append(packageInfo.Children, GetPackage(path.Join(packagePath, file.Name())))
		}
		if path.Ext(file.Name()) == ".fut" {
			
		}
	}
	return packageInfo
}