// Repository name use, must end with / or be '' for none
repository= 'area51/'

// image prefix
imagePrefix = 'babel'

// The targets to build - 'babel' must be first as it's common to all targets
// Ideally this is the order of the stages within Dockerfile
targets = [ 'babel', 'react' ]

properties( [
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '10')),
  disableConcurrentBuilds(),
  disableResume(),
  pipelineTriggers([
    upstream('/peter-mount/Node/master'),
  ])
])

// ======================================================================
// NO CONFIGURATION BELOW THIS POINT
// ======================================================================

// The architectures to build, in format recognised by docker
architectures = [ 'amd64', 'arm64v8' ]

// The tag prefix, '' for babel or the target for all others
def tagPrefix = { target -> target == 'babel' ? '' : target }

// The image version, master branch is latest in docker
version=BRANCH_NAME
if( version == 'master' ) {
  version = 'latest'
}

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

// target is either babel or react
// prefix is prefix to tag, '' for babel, 'react' for react
def buildArch = {
  architecture, target ->
    node( slaveId( architecture ) ) {
      stage( architecture ) {
        checkout scm
        sh 'docker pull area51/node:latest'

        sh 'docker build ' +
          '-t ' + dockerImage( tagPrefix( target ), architecture ) +
          ' --target ' + target +
          ' .'

        sh 'docker push ' + dockerImage( tagPrefix( target ), architecture )
      }
    }
}

def multiArchBuild = {
  target ->
    node( "AMD64" ) {
      stage( target + ' MultiArch' ) {
        // tag prefix
        prefix = tagPrefix( target )

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
}

// Build the image for a specific target
def buildImage = {
  target ->
    stage( target ) {
      parallel(
        'amd64': {
          buildArch( 'amd64', target )
        },
        'arm64v8': {
          buildArch( 'arm64v8', target )
        }
      )
    }

    multiArchBuild( target )
}

// Finally run the builds
targets.each { target -> buildImage( target ) }
