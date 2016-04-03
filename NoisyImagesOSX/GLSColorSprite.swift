//
//  GLSColorSprite.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 3/28/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import AppKit
import GLKit
import OmniSwiftX

class GLSColorSprite: GLSNode {
    
    struct Vertex {
        var position:(GLfloat, GLfloat) = (0.0, 0.0)
        var color:(GLfloat, GLfloat, GLfloat) = (0.0, 0.0, 0.0)
    }
    
    let colorVertices:TexturedQuadVertices<Vertex>
    
    let program = ShaderHelper.programDictionaryForString("Color Shader")!
    
    
    /*
     let program = ShaderProgram()
     let a_Position:GLuint
     var vertexBuffer:GLuint = 0
     */
    var cVerts = [GLfloat](count: 12, repeatedValue: 0.0)
    
    init(size:NSSize) {
        self.colorVertices = TexturedQuadVertices(vertex: Vertex(), count: 6)
        /*
         program.attachShader("ColorShader.vsh", withType: GL_VERTEX_SHADER)
         program.attachShader("ColorShader.fsh", withType: GL_FRAGMENT_SHADER)
         program.link()
         
         self.a_Position = program.getAttributeLocation("a_Position")!
         
         glGenBuffers(1, &self.vertexBuffer)
         glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
         */
        super.init(position: NSPoint.zero, size: size)
        self.colorVertices.iterateWithHandler() { index, vertex in
            vertex.position = (TexturedQuad.pointForIndex(index) * size).getGLTuple()
        }
        self.colorVertices[0].color = (1.0, 0.0, 0.0)
        self.colorVertices[1].color = (0.0, 1.0, 0.0)
        self.colorVertices[2].color = (0.0, 0.0, 1.0)
        self.colorVertices[3].color = (1.0, 1.0, 0.0)
        self.colorVertices[4].color = (1.0, 0.0, 1.0)
        self.colorVertices[5].color = (0.0, 1.0, 1.0)
    }
    
    override func render(model: SCMatrix4) {
        let childModel = self.modelMatrix() * model
        
//        glGenVertexArrays(1, &va)
//        glBindVertexArray(va)
        self.program.use()
        
        self.colorVertices.bufferDataWithVertexBuffer(self.program.vertexBuffer)
        
        let proj = self.projection
        glUniformMatrix4fv(self.program["u_Projection"], 1, 0, proj.values)
        
        self.program.enableAttributes()
        self.program.bridgeAttributesWithStride(sizeof(Vertex))
        //For some reason, GL_TRIANGLES is only drawing one triangle,
        //whereas GL_TRIANGLE_STRIP is drawing both. They might be flipped.
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(self.colorVertices.count))
//        self.program.disableAttributes()
        self.program.disable()
        
        /*
         glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
         //        glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(Vertex) * self.colorVertices.size, self.colorVertices.vertices, GLenum(GL_STATIC_DRAW))
         glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(GLfloat) * self.cVerts.count, self.cVerts, GLenum(GL_STATIC_DRAW))
         
         glEnableVertexAttribArray(self.a_Position)
         //        glVertexAttribPointer(self.a_Position, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Vertex)), nil)
         glVertexAttribPointer(self.a_Position, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
         
         
         glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(self.cVerts.count))
         
         glDisableVertexAttribArray(self.a_Position)
         */
        super.render(model)
    }
}
