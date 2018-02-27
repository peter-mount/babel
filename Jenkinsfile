// Repository name use, must end with / or be '' for none
repository= 'area51/'

// image prefix
imagePrefix = 'babel'

// The image version, master branch is latest in docker
version=BRANCH_NAME
if( version == 'master' ) {
  version = 'latest'
}

// The architectures to build, in format recognised by docker
architectures = [ 'amd64', 'arm64v8' ]

// The slave label based on architecture
def slaveId = {
  architecture -> switch( architecture ) {
    case 'amd64':
      return 'AMD64'
    case 'arm64v8':
      return 'ARM64'
    default:
      return 'amd64'
  }
}

// The docker image name
// architecture can be '' for multiarch images
def dockerImage = {
  prefix, architecture -> repository + imagePrefix + ':' +
    ( prefix=='' ? '' : ( prefix + '-' ) ) +
    ( architecture=='' ? '' : ( architecture + '-' ) ) +
    version
}

// The go arch
def goarch = {
  architecture -> switch( architecture ) {
    case 'amd64':
      return 'amd64'
    case 'arm32v6':
    case 'arm32v7':
      return 'arm'
    case 'arm64v8':
      return 'arm64'
    default:
      return architecture
  }
}

properties( [
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '10')),
  disableConcurrentBuilds(),
  disableResume(),
  pipelineTriggers([
    upstream('/Public/Node/master'),
  ])
])

architectures.each {
  architecture -> node( slaveId( architecture ) ) {
    stage( "Checkout " + architecture ) {
      checkout scm
      sh 'docker pull area51/node:latest'
    }

    stage( 'Babel ' + architecture ) {
      sh 'docker build -t ' + dockerImage( '', architecture ) + ' --target babel .'
    }

    stage( 'React ' + architecture ) {
      sh 'docker build -t ' + dockerImage( 'react', architecture ) + ' --target react .'
    }

    stage( 'Publish ' + architecture ) {
      sh 'docker push ' + dockerImage( '', architecture )
      sh 'docker push ' + dockerImage( 'react', architecture )
    }
  }
}

def multiArchBuild = {
  prefix, label -> stage( label + 'MultiArch' ) {
    // The manifest to publish
    multiImage = dockerImage( prefix, '' )

    // Create/amend the manifest with our architectures
    manifests = architectures.collect { architecture -> dockerImage( prefix, architecture ) }
    sh 'docker manifest create -a ' + multiImage + ' ' + manifests.join(' ')

    // For each architecture annotate them to be correct
    architectures.each {
      architecture -> sh 'docker manifest annotate' +
        ' --os linux' +
        ' --arch ' + goarch( architecture ) +
        ' ' + multiImage +
        ' ' + dockerImage( prefix, architecture )
    }

    // Publish the manifest
    sh 'docker manifest push -p ' + multiImage
  }
}

node( "AMD64" ) {
  multiArchBuild( '', 'babel' )
  multiArchBuild( 'react', 'react' )
}
